package com.bingomap.bingo_map.map;

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
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Overpass API에서 오사카시 전체 쓰레기통 데이터를 가져와
 * WASTE_BIN 테이블에 최초 1회 적재하는 로더.
 *
 * 실행 정책
 * 1. WASTE_BIN에 OSM_ID 데이터가 이미 있으면
 *    → Overpass 서버에 접속하지 않고 로더를 종료한다.
 *
 * 2. OSM_ID 데이터가 없으면
 *    → Overpass 서버에서 데이터를 받아 최초 적재한다.
 *
 * 3. 최초 적재 중 오류가 발생하면
 *    → 전체 INSERT를 rollback 한다.
 *    → 데이터가 반쪽만 들어간 상태로 남지 않게 한다.
 *
 * 4. 외부 Overpass 서버가 불안정한 경우
 *    → 3개의 미러를 순서대로 시도한다.
 *
 * 주의:
 * - 로컬 Oracle DB 연결은 항상 필요하다.
 * - 여기서 서버 연결이 선택적인 것은 외부 Overpass API 서버이다.
 */
public class WasteBinDbLoader {

    private static final String DB_URL =
            "jdbc:oracle:thin:@//localhost:1521/orcl";

    private static final String DB_USER = "scott";
    private static final String DB_PASSWORD = "tiger";

    private static final String[] OVERPASS_URLS = {
            "https://overpass-api.de/api/interpreter",
            "https://overpass.kumi.systems/api/interpreter",
            "https://maps.mail.ru/osm/tools/overpass/api/interpreter"
    };

    private static final String AREA_NAME = "大阪市";
    private static final String CITY = "osaka";

    public static void main(String[] args) {
        try {
            load();
        } catch (Exception e) {
            System.out.println("쓰레기통 데이터 로더 실행 실패");
            e.printStackTrace();
            System.exit(1);
        }
    }

    /**
     * 쓰레기통 데이터 적재.
     *
     * @throws Exception DB 연결, Overpass 요청, JSON 처리 또는 INSERT 실패 시
     */
    public static void load() throws Exception {

        System.out.println();
        System.out.println("========================================");
        System.out.println("WasteBinDbLoader 시작");
        System.out.println("========================================");

        try (Connection checkConn =
                     DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {

            int existingRows = countExistingOsmRows(checkConn);

            if (existingRows > 0) {
                System.out.println(
                        "기존 쓰레기통 OSM 데이터가 " + existingRows + "건 존재합니다."
                );
                System.out.println(
                        "Overpass 서버 접속을 생략하고 기존 DB 데이터를 사용합니다."
                );
                System.out.println("WasteBinDbLoader 종료.");
                System.out.println();

                return;
            }
        }

        String query = """
            [out:json][timeout:90];
            area["name"="%s"]["boundary"="administrative"]["admin_level"="7"]->.searchArea;
            (
              node["amenity"="waste_basket"](area.searchArea);
              node["amenity"="recycling"](area.searchArea);
            );
            out body;
            """.formatted(AREA_NAME);

        System.out.println(
                AREA_NAME + " 쓰레기통 데이터를 Overpass에서 요청합니다."
        );
        System.out.println(
                "최초 적재이므로 외부 서버 연결이 필요합니다."
        );

        String response = callOverpassWithFallback(query);

        if (response == null) {
            throw new IllegalStateException(
                    "모든 Overpass 서버 연결에 실패했습니다. " +
                            "DB에는 기존 OSM 데이터가 없어 최초 적재를 진행할 수 없습니다."
            );
        }

        JsonMapper mapper = JsonMapper.builder().build();
        JsonNode root = mapper.readTree(response);
        JsonNode elements = root.get("elements");

        if (elements == null || !elements.isArray() || elements.isEmpty()) {
            throw new IllegalStateException(
                    "Overpass 응답에 쓰레기통 데이터가 없습니다."
            );
        }

        System.out.println(
                "Overpass 응답 완료: " + elements.size() + "건"
        );
        System.out.println("DB 최초 적재를 시작합니다.");

        int inserted = 0;
        int skipped = 0;

        try (Connection conn =
                     DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {

            conn.setAutoCommit(false);

            try {

                String insertSql = """
                    INSERT INTO WASTE_BIN (
                        OSM_ID,
                        NAME,
                        CATEGORY,
                        ADDRESS,
                        LATITUDE,
                        LONGITUDE,
                        CITY
                    )
                    SELECT ?, ?, ?, ?, ?, ?, ?
                    FROM DUAL
                    WHERE NOT EXISTS (
                        SELECT 1
                        FROM WASTE_BIN
                        WHERE OSM_ID = ?
                    )
                    """;

                try (PreparedStatement ps =
                             conn.prepareStatement(insertSql)) {

                    int batchCount = 0;

                    for (JsonNode el : elements) {

                        if (!el.has("id")
                                || !el.has("lat")
                                || !el.has("lon")) {
                            continue;
                        }

                        long osmId =
                                el.get("id").asLong();

                        double lat =
                                el.get("lat").asDouble();

                        double lon =
                                el.get("lon").asDouble();

                        JsonNode tags =
                                el.get("tags");

                        String amenity =
                                tags != null && tags.has("amenity")
                                        ? tags.get("amenity").asText()
                                        : "waste_basket";

                        String category =
                                classifyCategory(
                                        amenity,
                                        tags
                                );

                        String name =
                                tags != null && tags.has("name")
                                        ? tags.get("name").asText()
                                        : categoryLabel(category);

                        String address =
                                extractAddress(tags);

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

                        if (batchCount % 500 == 0) {

                            int[] results =
                                    ps.executeBatch();

                            for (int result : results) {

                                if (result > 0
                                        || result == Statement.SUCCESS_NO_INFO) {
                                    inserted++;
                                } else {
                                    skipped++;
                                }
                            }

                            System.out.println(
                                    "  ... " + batchCount + "건 처리 중"
                            );
                        }
                    }

                    int[] results =
                            ps.executeBatch();

                    for (int result : results) {

                        if (result > 0
                                || result == Statement.SUCCESS_NO_INFO) {
                            inserted++;
                        } else {
                            skipped++;
                        }
                    }
                }

                conn.commit();

                System.out.println(
                        "쓰레기통 데이터 최초 적재 commit 완료"
                );

            } catch (Exception e) {

                try {
                    conn.rollback();
                } catch (SQLException rollbackException) {
                    e.addSuppressed(rollbackException);
                }

                System.out.println(
                        "최초 적재 중 오류 발생. 전체 rollback 완료."
                );

                throw e;
            }

        }

        System.out.println(
                "완료! 새로 저장: " + inserted +
                        "건, 중복으로 건너뜀: " + skipped + "건"
        );

        System.out.println(
                "최종 건수는 SELECT COUNT(*) FROM WASTE_BIN; 으로 확인하세요."
        );

        System.out.println("WasteBinDbLoader 종료.");
        System.out.println();
    }

    /**
     * WASTE_BIN에 이미 OSM 데이터가 있는지 확인.
     */
    private static int countExistingOsmRows(Connection conn)
            throws SQLException {

        String sql = """
                SELECT COUNT(*)
                FROM WASTE_BIN
                WHERE OSM_ID IS NOT NULL
                """;

        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }

            return 0;
        }
    }

    /**
     * amenity=waste_basket
     * → general
     *
     * amenity=recycling + 캔/유리
     * → can
     *
     * amenity=recycling 기타
     * → recycle
     */
    private static String classifyCategory(
            String amenity,
            JsonNode tags) {

        if (!"recycling".equals(amenity)) {
            return "general";
        }

        if (tags != null) {

            boolean cans =
                    "yes".equals(
                            textOrNull(tags, "recycling:cans")
                    );

            boolean glass =
                    "yes".equals(
                            textOrNull(tags, "recycling:glass_bottles")
                    );

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

        String street =
                textOrNull(tags, "addr:street");

        String houseNumber =
                textOrNull(tags, "addr:housenumber");

        if (street != null) {
            return houseNumber != null
                    ? street + " " + houseNumber
                    : street;
        }

        return "주소 정보 없음";
    }

    private static String textOrNull(
            JsonNode tags,
            String key) {

        return tags != null && tags.has(key)
                ? tags.get(key).asText()
                : null;
    }

    /**
     * Overpass 서버 미러를 순서대로 시도한다.
     */
    private static String callOverpassWithFallback(String query) {

        for (String url : OVERPASS_URLS) {

            try {

                String result =
                        postRequest(
                                url,
                                "data=" + query
                        );

                if (result != null) {
                    return result;
                }

            } catch (Exception e) {

                System.out.println(
                        url +
                                " 실패, 다음 미러 시도: " +
                                e.getMessage()
                );
            }
        }

        return null;
    }

    private static String postRequest(
            String urlStr,
            String body) throws Exception {

        URL url = new URL(urlStr);

        HttpURLConnection conn =
                (HttpURLConnection) url.openConnection();

        try {

            conn.setRequestMethod("POST");
            conn.setDoOutput(true);

            conn.setConnectTimeout(10_000);
            conn.setReadTimeout(130_000);

            try (OutputStream os =
                         conn.getOutputStream()) {

                os.write(
                        body.getBytes(
                                StandardCharsets.UTF_8
                        )
                );
            }

            int status =
                    conn.getResponseCode();

            if (status != 200) {
                throw new RuntimeException(
                        "HTTP " + status
                );
            }

            StringBuilder sb =
                    new StringBuilder();

            try (BufferedReader br =
                         new BufferedReader(
                                 new InputStreamReader(
                                         conn.getInputStream(),
                                         StandardCharsets.UTF_8
                                 )
                         )) {

                String line;

                while ((line = br.readLine()) != null) {
                    sb.append(line);
                }
            }

            return sb.toString();

        } finally {
            conn.disconnect();
        }
    }
}