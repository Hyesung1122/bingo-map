package com.bingomap.bingo_map.restaurant;

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
import java.util.HashMap;
import java.util.Map;

/**
 * Overpass API에서 오사카시 전체 테이크아웃 맛집을 가져와
 * RESTAURANTS 테이블에 최초 1회 적재하는 로더.
 *
 * 실행 정책
 * 1. RESTAURANTS에 OSM_ID 데이터가 이미 있으면
 *    → Overpass 서버에 접속하지 않는다.
 *
 * 2. OSM_ID 데이터가 없으면
 *    → Overpass 서버에서 최초 데이터를 가져온다.
 *
 * 3. 최초 적재 중 오류가 발생하면
 *    → 전체 INSERT를 rollback한다.
 *
 * 4. IS_PUBLISHED 값은 Loader의 실행 여부 판단 기준이 아니다.
 *    공개 여부는 DB/02_publication.sql이 관리한다.
 */
public class RestaurantDbLoader {

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

    private static final Map<String, String> CUISINE_MAP =
            new HashMap<>();

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

    public static void main(String[] args) {

        try {
            load();
        } catch (Exception e) {
            System.out.println(
                    "맛집 데이터 로더 실행 실패"
            );
            e.printStackTrace();
            System.exit(1);
        }
    }

    /**
     * 맛집 데이터 최초 적재.
     */
    public static void load() throws Exception {

        System.out.println();
        System.out.println("========================================");
        System.out.println("RestaurantDbLoader 시작");
        System.out.println("========================================");

        /*
         * 1. 기존 OSM 데이터 확인.
         */
        try (Connection checkConn =
                     DriverManager.getConnection(
                             DB_URL,
                             DB_USER,
                             DB_PASSWORD
                     )) {

            int existingRows =
                    countExistingOsmRows(checkConn);

            if (existingRows > 0) {

                System.out.println(
                        "기존 맛집 OSM 데이터가 "
                                + existingRows
                                + "건 존재합니다."
                );

                System.out.println(
                        "Overpass 서버 접속을 생략하고 "
                                + "기존 DB 데이터를 사용합니다."
                );

                System.out.println(
                        "RestaurantDbLoader 종료."
                );
                System.out.println();

                return;
            }
        }

        /*
         * 2. 최초 적재일 때만 Overpass API 호출.
         */
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

        System.out.println(
                AREA_NAME
                        + " 테이크아웃 맛집(체인 제외) "
                        + "데이터 요청 중..."
        );

        String response =
                callOverpassWithFallback(query);

        if (response == null) {

            throw new IllegalStateException(
                    "모든 Overpass 서버 연결에 실패했습니다. "
                            + "DB에는 기존 OSM 데이터가 없어 "
                            + "최초 맛집 데이터 적재를 진행할 수 없습니다."
            );
        }

        /*
         * 3. JSON 파싱.
         */
        JsonMapper mapper =
                JsonMapper.builder().build();

        JsonNode root =
                mapper.readTree(response);

        JsonNode elements =
                root.get("elements");

        if (elements == null
                || !elements.isArray()
                || elements.isEmpty()) {

            throw new IllegalStateException(
                    "Overpass 응답에 맛집 데이터가 없습니다."
            );
        }

        System.out.println(
                "Overpass 응답 완료: "
                        + elements.size()
                        + "건"
        );

        System.out.println(
                "DB 최초 적재를 시작합니다."
        );

        int inserted = 0;
        int skipped = 0;

        /*
         * 4. 전체 transaction.
         */
        try (Connection conn =
                     DriverManager.getConnection(
                             DB_URL,
                             DB_USER,
                             DB_PASSWORD
                     )) {

            conn.setAutoCommit(false);

            try {

                String insertSql = """
                        INSERT INTO RESTAURANTS (
                            RESTAURANT_ID,
                            OSM_ID,
                            NAME,
                            CATEGORY,
                            TAGS,
                            ADDRESS,
                            LATITUDE,
                            LONGITUDE,
                            OPENING_HOURS,
                            PHONE,
                            WEBSITE_URL,
                            IS_PUBLISHED,
                            CREATED_AT,
                            UPDATED_AT
                        )
                        SELECT
                            SEQ_RESTAURANT.NEXTVAL,
                            ?,
                            ?,
                            ?,
                            ?,
                            ?,
                            ?,
                            ?,
                            ?,
                            ?,
                            ?,
                            'N',
                            SYSTIMESTAMP,
                            SYSTIMESTAMP
                        FROM DUAL
                        WHERE NOT EXISTS (
                            SELECT 1
                            FROM RESTAURANTS
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

                        if (tags == null) {
                            continue;
                        }

                        String name =
                                textOrNull(
                                        tags,
                                        "name:ko"
                                );

                        if (name == null) {

                            name =
                                    textOrNull(
                                            tags,
                                            "name"
                                    );
                        }

                        if (name == null
                                || name.isBlank()) {
                            continue;
                        }

                        String cuisineRaw =
                                textOrNull(
                                        tags,
                                        "cuisine"
                                );

                        String category =
                                mapCategory(cuisineRaw);

                        String address =
                                extractAddress(tags);

                        String openingHours =
                                textOrNull(
                                        tags,
                                        "opening_hours"
                                );

                        String phone =
                                textOrNull(
                                        tags,
                                        "phone"
                                );

                        if (phone == null) {

                            phone =
                                    textOrNull(
                                            tags,
                                            "contact:phone"
                                    );
                        }

                        String website =
                                textOrNull(
                                        tags,
                                        "website"
                                );

                        ps.setLong(1, osmId);
                        ps.setString(2, name);
                        ps.setString(3, category);
                        ps.setString(4, cuisineRaw);
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

                            int[] results =
                                    ps.executeBatch();

                            for (int result : results) {

                                if (result > 0
                                        || result
                                        == Statement.SUCCESS_NO_INFO) {
                                    inserted++;
                                } else {
                                    skipped++;
                                }
                            }

                            System.out.println(
                                    "  ... "
                                            + batchCount
                                            + "건 처리 중"
                            );
                        }
                    }

                    /*
                     * 마지막 배치 실행.
                     */
                    int[] results =
                            ps.executeBatch();

                    for (int result : results) {

                        if (result > 0
                                || result
                                == Statement.SUCCESS_NO_INFO) {
                            inserted++;
                        } else {
                            skipped++;
                        }
                    }
                }

                /*
                 * 전체 성공 시에만 commit.
                 */
                conn.commit();

                System.out.println(
                        "맛집 데이터 최초 적재 commit 완료"
                );

            } catch (Exception e) {

                try {
                    conn.rollback();
                } catch (SQLException rollbackException) {
                    e.addSuppressed(
                            rollbackException
                    );
                }

                System.out.println(
                        "맛집 최초 적재 중 오류 발생. "
                                + "전체 rollback 완료."
                );

                throw e;
            }
        }

        System.out.println(
                "완료! 새로 저장: "
                        + inserted
                        + "건, 중복으로 건너뜀: "
                        + skipped
                        + "건"
        );

        System.out.println(
                "메뉴/가격/평점/사진/설명은 "
                        + "OSM에 없어서 NULL입니다."
        );

        System.out.println(
                "RestaurantDbLoader 종료."
        );
        System.out.println();
    }

    /**
     * RESTAURANTS에 OSM 데이터가 이미 존재하는지 확인한다.
     *
     * OSM_ID가 NULL인 기존 수기 데이터가 있더라도
     * Loader가 최초 적재를 수행할 수 있도록 한다.
     */
    private static int countExistingOsmRows(
            Connection conn) throws SQLException {

        String sql = """
                SELECT COUNT(*)
                FROM RESTAURANTS
                WHERE OSM_ID IS NOT NULL
                """;

        try (PreparedStatement ps =
                     conn.prepareStatement(sql);
             ResultSet rs =
                     ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }

            return 0;
        }
    }

    private static String mapCategory(
            String cuisineRaw) {

        if (cuisineRaw == null
                || cuisineRaw.isBlank()) {
            return "기타";
        }

        String first =
                cuisineRaw
                        .split(";")[0]
                        .trim()
                        .toLowerCase();

        return CUISINE_MAP.getOrDefault(
                first,
                cuisineRaw
        );
    }

    private static String extractAddress(
            JsonNode tags) {

        String suburb =
                textOrNull(
                        tags,
                        "addr:suburb"
                );

        String neighbourhood =
                textOrNull(
                        tags,
                        "addr:neighbourhood"
                );

        String block =
                textOrNull(
                        tags,
                        "addr:block_number"
                );

        String house =
                textOrNull(
                        tags,
                        "addr:housenumber"
                );

        StringBuilder sb =
                new StringBuilder();

        if (suburb != null) {
            sb.append(suburb);
        }

        if (neighbourhood != null) {
            appendWithSpace(
                    sb,
                    neighbourhood
            );
        }

        if (block != null) {
            appendWithSpace(
                    sb,
                    block
            );
            sb.append("-");
        }

        if (house != null) {
            sb.append(house);
        }

        String result =
                sb.toString().trim();

        return result.isEmpty()
                ? "주소 정보 없음"
                : result;
    }

    private static void appendWithSpace(
            StringBuilder sb,
            String value) {

        if (sb.length() > 0) {
            sb.append(" ");
        }

        sb.append(value);
    }

    private static String textOrNull(
            JsonNode tags,
            String key) {

        return tags != null && tags.has(key)
                ? tags.get(key).asText()
                : null;
    }

    private static String callOverpassWithFallback(
            String query) {

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
                        url
                                + " 실패, 다음 미러 시도: "
                                + e.getMessage()
                );
            }
        }

        return null;
    }

    private static String postRequest(
            String urlStr,
            String body) throws Exception {

        URL url =
                new URL(urlStr);

        HttpURLConnection conn =
                (HttpURLConnection)
                        url.openConnection();

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