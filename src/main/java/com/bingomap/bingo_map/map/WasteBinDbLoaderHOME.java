package com.bingomap.bingo_map.map;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/** 수동 1회 적재 도구. 웹 서버 시작 시 자동 실행되지 않습니다. */
public class WasteBinDbLoaderHOME {
    // IntelliJ 실행 구성의 환경 변수로 웹 서버와 같은 DB를 지정합니다.
    // 집 기본값은 XE/SCOTT이며 비밀번호는 코드에 저장하지 않습니다.
    private static final String DB_URL = env("SPRING_DATASOURCE_URL", "jdbc:oracle:thin:@//localhost:1521/xe");
    private static final String DB_USER = env("SPRING_DATASOURCE_USERNAME", "scott");
    private static final String CITY = "osaka";
    private static final String[] OVERPASS_URLS = {
            "https://overpass-api.de/api/interpreter",
            "https://overpass.private.coffee/api/interpreter"
    };
    private static final String QUERY = """
            [out:json][timeout:90];
            area["name"="大阪市"]["boundary"="administrative"]["admin_level"="7"]->.searchArea;
            (
              node["amenity"="waste_basket"](area.searchArea);
              node["amenity"="recycling"](area.searchArea);
            );
            out body;
            out count;
            """;

    public static void main(String[] args) throws Exception {
        String password = System.getenv("SPRING_DATASOURCE_PASSWORD");
        if (password == null || password.isBlank()) {
            throw new IllegalStateException("실행 구성의 환경 변수에 SPRING_DATASOURCE_PASSWORD를 넣으세요. "
                    + "application.yaml의 집 SCOTT 비밀번호와 같은 값입니다.");
        }
        // 수정: 먼저 집 DB 접속/테이블을 확인합니다. DB가 잘못된 상태로 OSM 요청부터 하지 않습니다.
        try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, password)) {
            var layout = WasteBinSchema.importLayout(connection);
            try (Statement statement = connection.createStatement();
                 ResultSet result = statement.executeQuery("SELECT USER, "
                         + "SYS_CONTEXT('USERENV', 'SERVICE_NAME') FROM DUAL")) {
                result.next();
                System.out.println("DB 사용자=" + result.getString(1)
                        + ", 서비스=" + result.getString(2) + ", 번호 컬럼=" + layout.idColumn()
                        + ", 시퀀스=" + layout.sequenceName());
            }
        }

        System.out.println("오사카시 OSM 데이터 요청 중...");
        List<Bin> bins = fetchBins();
        try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, password)) {
            int inserted = importBins(connection, bins);
            System.out.println("완료: 새로 저장 " + inserted + "건, 이미 존재 "
                    + (bins.size() - inserted) + "건. CITY=osaka");
        }
        System.out.println("BingoMapApplication으로 서버를 실행하고 /api/bins?city=osaka를 확인하세요.");
    }

    static int importBins(Connection connection, List<Bin> bins) throws SQLException {
        connection.setAutoCommit(false);
        try {
            var layout = WasteBinSchema.importLayout(connection);
            String idColumn = layout.idColumn();
            String sequence = layout.sequenceName();
            long maxId;
            long nextId;
            try (Statement statement = connection.createStatement();
                 ResultSet result = statement.executeQuery("SELECT NVL(MAX(" + idColumn + "), 0) FROM WASTE_BIN")) {
                result.next();
                maxId = result.getLong(1);
            }
            try (Statement statement = connection.createStatement();
                 ResultSet result = statement.executeQuery("SELECT " + sequence + ".NEXTVAL FROM DUAL")) {
                result.next();
                nextId = result.getLong(1);
            }
            if (nextId <= maxId) {
                throw new SQLException(sequence + "이 기존 최대 번호보다 뒤에 있습니다. "
                        + "기존 데이터는 변경하지 않았습니다. 시퀀스 정렬 후 다시 실행하세요. "
                        + "MAX_ID=" + maxId + ", NEXT_ID=" + nextId);
            }

            // 수정: 누락됐던 번호 생성을 복구. 트리거 유무와 관계없이 번호를 제공합니다.
            String sql = "INSERT INTO WASTE_BIN (" + idColumn + ", OSM_ID, NAME, CATEGORY, ADDRESS, "
                    + "LATITUDE, LONGITUDE, CITY" + layout.dateColumns() + ") "
                    + "SELECT " + sequence + ".NEXTVAL, ?, ?, ?, ?, ?, ?, ?"
                    + layout.dateValues() + " FROM DUAL "
                    + "WHERE NOT EXISTS (SELECT 1 FROM WASTE_BIN WHERE OSM_ID = ?)";
            int inserted = 0;
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                for (Bin bin : bins) {
                    statement.setLong(1, bin.osmId());
                    statement.setString(2, bin.name());
                    statement.setString(3, bin.category());
                    statement.setString(4, bin.address());
                    statement.setDouble(5, bin.lat());
                    statement.setDouble(6, bin.lon());
                    statement.setString(7, CITY);
                    statement.setLong(8, bin.osmId());
                    inserted += statement.executeUpdate();
                }
            }
            connection.commit();
            return inserted;
        } catch (SQLException | RuntimeException failure) {
            try { connection.rollback(); }
            catch (SQLException rollbackFailure) { failure.addSuppressed(rollbackFailure); }
            throw failure;
        }
        // 시퀀스 번호 자체는 Oracle 특성상 rollback되지 않아 중간에 빈 번호가 생길 수 있습니다.
    }

    private static List<Bin> fetchBins() throws IOException {
        IOException last = null;
        for (String endpoint : OVERPASS_URLS) {
            try {
                return parseBins(post(endpoint));
            } catch (IOException | RuntimeException failure) {
                last = new IOException("OSM 수집 실패. DB 데이터는 유지됩니다.", failure);
                System.out.println(endpoint + " 수집 실패: " + failure.getMessage());
            }
        }
        throw last == null ? new IOException("OSM 서버가 설정되지 않았습니다.") : last;
    }

    static List<Bin> parseBins(String json) {
        JsonNode root = JsonMapper.builder().build().readTree(json);
        if (root == null || !root.isObject() || root.hasNonNull("remark")) {
            throw new IllegalArgumentException("OSM 오류 또는 부분 응답입니다.");
        }
        JsonNode elements = root.get("elements");
        if (elements == null || !elements.isArray()) {
            throw new IllegalArgumentException("OSM elements가 없습니다.");
        }
        List<Bin> bins = new ArrayList<>();
        Set<Long> ids = new HashSet<>();
        JsonNode count = null;
        for (JsonNode element : elements) {
            if ("count".equals(element.path("type").asText())) {
                if (count != null) throw new IllegalArgumentException("OSM count 중복");
                count = element;
                continue;
            }
            if (count != null || !"node".equals(element.path("type").asText())
                    || !element.path("id").isIntegralNumber()
                    || !element.path("lat").isNumber() || !element.path("lon").isNumber()) {
                throw new IllegalArgumentException("OSM 노드 형식 또는 응답 순서가 잘못됐습니다.");
            }
            long id = element.path("id").asLong();
            double lat = element.path("lat").asDouble();
            double lon = element.path("lon").asDouble();
            if (id <= 0 || !ids.add(id) || !Double.isFinite(lat) || !Double.isFinite(lon)
                    || lat < -90 || lat > 90 || lon < -180 || lon > 180) {
                throw new IllegalArgumentException("OSM ID/좌표 중복 또는 범위 오류");
            }
            JsonNode tags = element.path("tags");
            String amenity = tags.path("amenity").asText();
            if (!"waste_basket".equals(amenity) && !"recycling".equals(amenity)) {
                throw new IllegalArgumentException("쓰레기통 이외의 OSM 객체가 포함됐습니다.");
            }
            String category = "general";
            if ("recycling".equals(amenity)) {
                category = "yes".equals(tags.path("recycling:cans").asText())
                        || "yes".equals(tags.path("recycling:glass_bottles").asText()) ? "can" : "recycle";
            }
            String fallback = switch (category) {
                case "can" -> "캔/병 수거함";
                case "recycle" -> "재활용 수거함";
                default -> "쓰레기통";
            };
            String name = tags.path("name").asText("");
            String street = tags.path("addr:street").asText("");
            String house = tags.path("addr:housenumber").asText("");
            String address = street.isBlank() ? "주소 정보 없음" : (street + " " + house).trim();
            bins.add(new Bin(id, lat, lon, name.isBlank() ? fallback : name, category, address));
        }
        // 완료 count가 없거나 0건이면 기존 데이터 보존 후 중단합니다.
        if (count == null || bins.isEmpty()
                || count.path("tags").path("total").asInt(-1) != bins.size()
                || count.path("tags").path("nodes").asInt(-1) != bins.size()) {
            throw new IllegalArgumentException("OSM 수집이 완료되지 않았거나 0건입니다. 기존 DB를 유지합니다.");
        }
        return bins;
    }

    private static String post(String endpoint) throws IOException {
        HttpURLConnection connection = (HttpURLConnection) URI.create(endpoint).toURL().openConnection();
        try {
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
            connection.setConnectTimeout(10_000);
            connection.setReadTimeout(130_000);
            connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
            byte[] body = ("data=" + URLEncoder.encode(QUERY, StandardCharsets.UTF_8)).getBytes(StandardCharsets.UTF_8);
            try (var output = connection.getOutputStream()) { output.write(body); }
            int status = connection.getResponseCode();
            if (status != 200) throw new IOException("HTTP " + status);
            try (var input = connection.getInputStream()) {
                byte[] bytes = input.readNBytes(10_000_001);
                if (bytes.length > 10_000_000) throw new IOException("OSM 응답 크기 제한 초과");
                return new String(bytes, StandardCharsets.UTF_8);
            }
        } finally {
            connection.disconnect();
        }
    }

    private static String env(String name, String fallback) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? fallback : value.trim();
    }

    record Bin(long osmId, double lat, double lon, String name, String category, String address) {}
}
