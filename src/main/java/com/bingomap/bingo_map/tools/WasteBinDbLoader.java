package com.bingomap.bingo_map.tools;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

/**
 * Overpass API에서 "오사카시 전체" 쓰레기통 데이터를 가져와 WASTE_BIN 테이블에 적재.
 *
 * 도톤보리 버전과 차이점:
 * - 좌표 박스(BBOX) 대신 행정구역 이름(area["name"="大阪市"])으로 지정 → 경계가 정확함
 * - 도시 단위라 응답이 커질 수 있어 Overpass timeout(90초)과 자바 read timeout(130초)을 늘림
 * - 데이터가 많아질 걸 대비해 배치(batch) INSERT로 변경
 *
 * 실행 방법은 기존과 동일: IntelliJ에서 main() 옆 ▶ 실행.
 * OSM_ID가 UNIQUE라서, 도톤보리 때 넣은 7건은 자동으로 건너뛰고 나머지만 새로 들어감.
 */
public class WasteBinDbLoader {

    private static final String DB_URL = "jdbc:oracle:thin:@//localhost:1521/orcl";
    private static final String DB_USER = "scott";
    private static final String DB_PASSWORD = "tiger";

    private static final String[] OVERPASS_URLS = {
            "https://overpass-api.de/api/interpreter",
            "https://overpass.kumi.systems/api/interpreter",
            "https://maps.mail.ru/osm/tools/overpass/api/interpreter"
    };

    // 행정구역 이름으로 오사카시 전체 지정. 다른 시로 넓힐 땐 이 이름만 바꾸면 됨.
    private static final String AREA_NAME = "大阪市";
    private static final String CITY = "osaka";

    public static void main(String[] args) throws Exception {

        String query = """
                [out:json][timeout:90];
                area["name"="%s"]["boundary"="administrative"]["admin_level"="7"]->.searchArea;
                (
                  node["amenity"="waste_basket"](area.searchArea);
                  node["amenity"="recycling"](area.searchArea);
                );
                out body;
                """.formatted(AREA_NAME);

        System.out.println(AREA_NAME + " 데이터 요청 중... (도시 단위라 몇십 초 걸릴 수 있어요)");
        String response = callOverpassWithFallback(query);
        if (response == null) {
            System.out.println("모든 Overpass 서버 응답 실패. 잠시 후 다시 시도해주세요.");
            return;
        }

        JsonMapper mapper = JsonMapper.builder().build();
        JsonNode root = mapper.readTree(response);
        JsonNode elements = root.get("elements");

        if (elements == null || !elements.isArray() || elements.isEmpty()) {
            System.out.println("Overpass 응답에 데이터가 없습니다. AREA_NAME 철자를 확인해보세요.");
            return;
        }

        System.out.println("Overpass 응답 받음: " + elements.size() + "건. DB 적재 시작...");

        int inserted = 0;
        int skipped = 0;

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            conn.setAutoCommit(false);

            String insertSql = """
                    INSERT INTO WASTE_BIN (BIN_ID, OSM_ID, NAME, CATEGORY, ADDRESS, LATITUDE, LONGITUDE, CITY)
                    SELECT SEQ_WASTE_BIN.NEXTVAL, ?, ?, ?, ?, ?, ?, ?
                    FROM DUAL
                    WHERE NOT EXISTS (
                        SELECT 1 FROM WASTE_BIN WHERE OSM_ID = ?
                    )
                    """;

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {

                int batchCount = 0;
                for (JsonNode el : elements) {
                    long osmId = el.get("id").asLong();
                    double lat = el.get("lat").asDouble();
                    double lon = el.get("lon").asDouble();

                    JsonNode tags = el.get("tags");
                    String amenity = (tags != null && tags.has("amenity"))
                            ? tags.get("amenity").asText() : "waste_basket";

                    String category = classifyCategory(amenity, tags);

                    String name = (tags != null && tags.has("name"))
                            ? tags.get("name").asText() : categoryLabel(category);

                    String address = extractAddress(tags);

                    ps.setLong(1, osmId);
                    ps.setString(2, name);
                    ps.setString(3, category);
                    ps.setString(4, address);
                    ps.setDouble(5, lat);
                    ps.setDouble(6, lon);
                    ps.setString(7, CITY);
                    ps.setLong(8, osmId);
                    ps.addBatch();
                    batchCount++;

                    // 500건마다 한 번씩 배치 실행 (한 번에 너무 몰아서 처리하지 않도록)
                    if (batchCount % 500 == 0) {
                        int[] results = ps.executeBatch();
                        for (int r : results) {
                            if (r > 0 || r == java.sql.Statement.SUCCESS_NO_INFO) inserted++;
                            else skipped++;
                        }
                        conn.commit();
                        System.out.println("  ... " + batchCount + "건 처리 중");
                    }
                }
                int[] results = ps.executeBatch();
                for (int r : results) {
                    if (r > 0 || r == java.sql.Statement.SUCCESS_NO_INFO) inserted++;
                    else skipped++;
                }
                conn.commit();
            }
        }

        System.out.println("완료! 새로 저장 시도: " + inserted + "건, 이미 있어서 건너뜀: " + skipped + "건");
        System.out.println("(정확한 최종 건수는 DB에서 SELECT COUNT(*) FROM WASTE_BIN; 으로 확인하세요)");
    }

    /**
     * amenity=waste_basket        → general (일반쓰레기)
     * amenity=recycling + 캔/유리  → can (캔/병)
     * amenity=recycling (그 외)   → recycle (재활용)
     */
    private static String classifyCategory(String amenity, JsonNode tags) {
        if (!"recycling".equals(amenity)) {
            return "general";
        }
        if (tags != null) {
            boolean cans = "yes".equals(textOrNull(tags, "recycling:cans"));
            boolean glass = "yes".equals(textOrNull(tags, "recycling:glass_bottles"));
            if (cans || glass) {
                return "can";
            }
        }
        return "recycle";
    }

    private static String categoryLabel(String category) {
        return switch (category) {
            case "can" -> "캔/병 수거함";
            case "recycle" -> "재활용 수거함";
            default -> "쓰레기통";
        };
    }

    private static String extractAddress(JsonNode tags) {
        if (tags == null) {
            return "주소 정보 없음";
        }
        String street = textOrNull(tags, "addr:street");
        String houseNumber = textOrNull(tags, "addr:housenumber");
        if (street != null) {
            return houseNumber != null ? street + " " + houseNumber : street;
        }
        return "주소 정보 없음";
    }

    private static String textOrNull(JsonNode tags, String key) {
        return tags.has(key) ? tags.get(key).asText() : null;
    }

    /** 서버 하나가 죽어있으면 다음 미러로 넘어가며 시도 */
    private static String callOverpassWithFallback(String query) {
        for (String url : OVERPASS_URLS) {
            try {
                String result = postRequest(url, "data=" + query);
                if (result != null) {
                    return result;
                }
            } catch (Exception e) {
                System.out.println(url + " 실패, 다음 미러 시도: " + e.getMessage());
            }
        }
        return null;
    }

    private static String postRequest(String urlStr, String body) throws Exception {
        URL url = new URL(urlStr);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setConnectTimeout(10_000);
        conn.setReadTimeout(130_000); // Overpass timeout(90s)보다 넉넉하게

        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }

        int status = conn.getResponseCode();
        if (status != 200) {
            throw new RuntimeException("HTTP " + status);
        }

        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }
}
