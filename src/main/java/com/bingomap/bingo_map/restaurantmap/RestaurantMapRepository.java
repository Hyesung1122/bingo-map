package com.bingomap.bingo_map.restaurantmap;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import static com.bingomap.bingo_map.restaurantmap.RestaurantMapModels.Place;

@Repository
public class RestaurantMapRepository {
    private final JdbcTemplate jdbc;
    public RestaurantMapRepository(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    // 업로드된 SQL의 실제 테이블은 TB_RESTAURANTS가 아니라 RESTAURANT입니다.
    // 현재는 팀이 선별해 넣은 소규모 목록을 조회합니다.
    // 도시 전체로 데이터가 늘어나면 화면 범위 조건과 결과 개수 제한을 추가하세요.
    static final String SQL = """
        SELECT RESTAURANT_ID, NAME, CATEGORY, TAGS, RATING, REVIEW_COUNT,
               DESCRIPTION, ADDRESS, LATITUDE, LONGITUDE, OPENING_HOURS,
               PHONE, PRICE_RANGE, WEBSITE_URL, SEAT_INFO, RESERVATION_INFO,
               PAYMENT_METHODS, LANGUAGES, MAIN_IMAGE_URL,
               MENU_NAME, MENU_DESCRIPTION, MENU_PRICE, MENU_IMAGE_URL
        FROM RESTAURANT
        ORDER BY RESTAURANT_ID
        """;

    public List<Place> findAll() { return jdbc.query(SQL, (rs, index) -> read(rs)); }

    static Place read(ResultSet rs) throws SQLException {
        long id = rs.getLong("RESTAURANT_ID");
        return new Place(Long.toString(id), id, text(rs,"NAME"), text(rs,"CATEGORY"), text(rs,"TAGS"),
                rs.getBigDecimal("RATING"), nullableLong(rs,"REVIEW_COUNT"), text(rs,"DESCRIPTION"),
                text(rs,"ADDRESS"), coordinate(rs,"LATITUDE"), coordinate(rs,"LONGITUDE"),
                text(rs,"OPENING_HOURS"), text(rs,"PHONE"), text(rs,"PRICE_RANGE"), text(rs,"WEBSITE_URL"),
                text(rs,"SEAT_INFO"), text(rs,"RESERVATION_INFO"), text(rs,"PAYMENT_METHODS"),
                text(rs,"LANGUAGES"), text(rs,"MAIN_IMAGE_URL"), text(rs,"MENU_NAME"),
                text(rs,"MENU_DESCRIPTION"), text(rs,"MENU_PRICE"), text(rs,"MENU_IMAGE_URL"));
    }

    static boolean hasCoordinates(Place p) {
        return p.lat() != null && p.lon() != null && Double.isFinite(p.lat()) && Double.isFinite(p.lon())
                && Math.abs(p.lat()) <= 90 && Math.abs(p.lon()) <= 180;
    }

    private static Double coordinate(ResultSet rs, String key) throws SQLException {
        double value = rs.getDouble(key);
        return rs.wasNull() ? null : value; // NULL을 0도 좌표로 표시하지 않습니다.
    }
    private static Long nullableLong(ResultSet rs, String key) throws SQLException {
        long value = rs.getLong(key); return rs.wasNull() ? null : value;
    }
    private static String text(ResultSet rs, String key) throws SQLException {
        String value = rs.getString(key); return value == null ? "" : value;
    }
}
