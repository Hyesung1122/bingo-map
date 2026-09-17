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
import java.util.HashMap;
import java.util.Map;

/**
 * Overpass API에서 "오사카시 전체 테이크아웃 맛집(체인 브랜드 제외)"을 가져와
 * RESTAURANT 테이블에 적재하는 도구.
 *
 * WasteBinDbLoader와 같은 구조. 실행 전에 06_add_osm_id_to_restaurant.sql을
 * 먼저 실행해서 RESTAURANT 테이블에 OSM_ID 컬럼이 있어야 함.
 *
 * OSM에는 메뉴/가격/평점/설명/사진이 없어서 그 컬럼들은 NULL로 들어감.
 * 기존 5개 수기 샘플 데이터는 OSM_ID가 NULL이라 영향받지 않음.
 *
 * 실행 방법: IntelliJ에서 main() 옆 ▶ 실행 (기존 도구들과 동일).
 */
public class RestaurantDbLoader {

    private static final String DB_URL = "jdbc:oracle:thin:@//localhost:1521/orcl";
    private static final String DB_USER = "scott";
    private static final String DB_PASSWORD = "tiger";

    private static final String[] OVERPASS_URLS = {
            "https://overpass-api.de/api/interpreter",
            "https://overpass.kumi.systems/api/interpreter",
            "https://maps.mail.ru/osm/tools/overpass/api/interpreter"
    };

    private static final String AREA_NAME = "大阪市";

    // OSM cuisine(영어) → 화면에 쓸 한국어 카테고리 매핑
    private static final Map<String, String> CUISINE_MAP = new HashMap<>();
    static {
        CUISINE_MAP.put("burger", "버거");
        CUISINE_MAP.put("coffee_shop", "카페");
        CUISINE_MAP.put("ramen", "라멘");
        CUISINE_MAP.put("japanese", "일식");
        CUISINE_MAP.put("chicken", "치킨");
        CUISINE_MAP.put("donut", "도넛");
        CUISINE_MAP.put("sandwich", "샌드위치");
        CUISINE_MAP.put("pizza", "피자");
        CUISINE_MAP.put("udon", "우동");
        CUISINE_MAP.put("soba", "소바");
        CUISINE_MAP.put("sushi", "초밥");
        CUISINE_MAP.put("yakitori", "야키토리");
        CUISINE_MAP.put("izakaya", "이자카야");
        CUISINE_MAP.put("korean", "한식");
        CUISINE_MAP.put("chinese", "중식");
        CUISINE_MAP.put("italian", "이탈리안");
        CUISINE_MAP.put("bakery", "베이커리");
        CUISINE_MAP.put("dessert", "디저트");
        CUISINE_MAP.put("ice_cream", "아이스크림");
        CUISINE_MAP.put("curry", "카레");
        CUISINE_MAP.put("okonomiyaki", "오코노미야끼");
        CUISINE_MAP.put("takoyaki", "타코야끼");
        CUISINE_MAP.put("noodle", "면요리");
        CUISINE_MAP.put("asian", "아시안");
        CUISINE_MAP.put("seafood", "해산물");
    }

    public static void main(String[] args) throws Exception {

        String query = """
                [out:json][timeout:90];
                area["name"="%s"]["boundary"="administrative"]["admin_level"="7"]->.a;
                (
                  node["amenity"="fast_food"]["name"]["takeaway"~"yes|only"][!"brand"](area.a);
                  node["amenity"="cafe"]["name"][!"brand"](area.a);
                  node["amenity"="restaurant"]["name"]["takeaway"~"yes|only"][!"brand"](area.a);
                );
                out body;
                """.formatted(AREA_NAME);

        System.out.println(AREA_NAME + " 테이크아웃 맛집(체인 제외) 요청 중... (몇십 초 걸릴 수 있어요)");
        String response = callOverpassWithFallback(query);
        if (response == null) {
            System.out.println("모든 Overpass 서버 응답 실패. 잠시 후 다시 시도해주세요.");
            return;
        }

        JsonMapper mapper = JsonMapper.builder().build();
        JsonNode root = mapper.readTree(response);
        JsonNode elements = root.get("elements");

        if (elements == null || !elements.isArray() || elements.isEmpty()) {
            System.out.println("Overpass 응답에 데이터가 없습니다.");
            return;
        }

        System.out.println("Overpass 응답 받음: " + elements.size() + "건. DB 적재 시작...");

        int inserted = 0;
        int skipped = 0;

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            conn.setAutoCommit(false);

            String insertSql = """
                    INSERT INTO RESTAURANT (
                        RESTAURANT_ID, OSM_ID, NAME, CATEGORY, TAGS,
                        ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS, PHONE, WEBSITE_URL
                    )
                    SELECT SEQ_RESTAURANT.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                    FROM DUAL
                    WHERE NOT EXISTS (
                        SELECT 1 FROM RESTAURANT WHERE OSM_ID = ?
                    )
                    """;

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {

                int batchCount = 0;
                for (JsonNode el : elements) {
                    long osmId = el.get("id").asLong();
                    double lat = el.get("lat").asDouble();
                    double lon = el.get("lon").asDouble();

                    JsonNode tags = el.get("tags");
                    if (tags == null) continue;

                    String name = textOrNull(tags, "name:ko");
                    if (name == null) name = textOrNull(tags, "name");
                    if (name == null) continue; // 이름 없으면 건너뜀 (쿼리상 거의 없음)

                    String cuisineRaw = textOrNull(tags, "cuisine");
                    String category = mapCategory(cuisineRaw);
                    String address = extractAddress(tags);
                    String openingHours = textOrNull(tags, "opening_hours");
                    String phone = textOrNull(tags, "phone");
                    if (phone == null) phone = textOrNull(tags, "contact:phone");
                    String website = textOrNull(tags, "website");

                    ps.setLong(1, osmId);
                    ps.setString(2, name);
                    ps.setString(3, category);
                    ps.setString(4, cuisineRaw); // 원본 cuisine 값을 TAGS에 참고용으로 저장
                    ps.setString(5, address);
                    ps.setDouble(6, lat);
                    ps.setDouble(7, lon);
                    ps.setString(8, openingHours);
                    ps.setString(9, phone);
                    ps.setString(10, website);
                    ps.setLong(11, osmId);
                    ps.addBatch();
                    batchCount++;

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
        System.out.println("(메뉴/가격/평점/사진/설명은 OSM에 없어서 NULL입니다 — 이후 수동으로 채워야 해요)");
    }

    private static String mapCategory(String cuisineRaw) {
        if (cuisineRaw == null) return "기타";
        // cuisine은 세미콜론으로 여러 값이 붙기도 함 (예: "coffee_shop;sandwich") → 첫 값만 사용
        String first = cuisineRaw.split(";")[0].trim().toLowerCase();
        return CUISINE_MAP.getOrDefault(first, cuisineRaw);
    }

    private static String extractAddress(JsonNode tags) {
        String suburb = textOrNull(tags, "addr:suburb");
        String neighbourhood = textOrNull(tags, "addr:neighbourhood");
        String block = textOrNull(tags, "addr:block_number");
        String house = textOrNull(tags, "addr:housenumber");

        StringBuilder sb = new StringBuilder();
        if (suburb != null) sb.append(suburb);
        if (neighbourhood != null) sb.append(" ").append(neighbourhood);
        if (block != null) sb.append(" ").append(block).append("-");
        if (house != null) sb.append(house);

        String result = sb.toString().trim();
        return result.isEmpty() ? "주소 정보 없음" : result;
    }

    private static String textOrNull(JsonNode tags, String key) {
        return tags.has(key) ? tags.get(key).asText() : null;
    }

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
        conn.setReadTimeout(130_000);

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
