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

    public RestaurantMapRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /**
     * 주변 맛집 페이지와 지도에서 사용하는 식당 조회.
     *
     * 최종 통합 DB:
     * RESTAURANTS
     *
     * 공개된 식당(IS_PUBLISHED = 'Y')만 가져옵니다.
     */
    private static final String SQL = """
        SELECT
            RESTAURANT_ID,
            NAME,
            CATEGORY,
            TAGS,
            RATING,
            REVIEW_COUNT,
            DESCRIPTION,
            ADDRESS,
            LATITUDE,
            LONGITUDE,
            OPENING_HOURS,
            PHONE,
            PRICE_RANGE,
            WEBSITE_URL,
            SEAT_INFO,
            RESERVATION_INFO,
            PAYMENT_METHODS,
            LANGUAGES,
            MAIN_IMAGE_URL,
            MENU_NAME,
            MENU_DESCRIPTION,
            MENU_PRICE,
            MENU_IMAGE_URL
        FROM RESTAURANTS
        WHERE IS_PUBLISHED = 'Y'
        ORDER BY RESTAURANT_ID
        """;

    public List<Place> findAll() {
        return jdbc.query(
                SQL,
                (rs, rowNum) -> read(rs)
        );
    }

    static Place read(ResultSet rs) throws SQLException {

        long id = rs.getLong("RESTAURANT_ID");

        return new Place(
                String.valueOf(id),
                id,
                text(rs, "NAME"),
                text(rs, "CATEGORY"),
                text(rs, "TAGS"),
                rs.getBigDecimal("RATING"),
                nullableLong(rs, "REVIEW_COUNT"),
                text(rs, "DESCRIPTION"),
                text(rs, "ADDRESS"),
                coordinate(rs, "LATITUDE"),
                coordinate(rs, "LONGITUDE"),
                text(rs, "OPENING_HOURS"),
                text(rs, "PHONE"),
                text(rs, "PRICE_RANGE"),
                text(rs, "WEBSITE_URL"),
                text(rs, "SEAT_INFO"),
                text(rs, "RESERVATION_INFO"),
                text(rs, "PAYMENT_METHODS"),
                text(rs, "LANGUAGES"),
                text(rs, "MAIN_IMAGE_URL"),
                text(rs, "MENU_NAME"),
                text(rs, "MENU_DESCRIPTION"),
                text(rs, "MENU_PRICE"),
                text(rs, "MENU_IMAGE_URL")
        );
    }

    static boolean hasCoordinates(Place p) {
        return p.lat() != null
                && p.lon() != null
                && Double.isFinite(p.lat())
                && Double.isFinite(p.lon())
                && Math.abs(p.lat()) <= 90
                && Math.abs(p.lon()) <= 180;
    }

    private static Double coordinate(
            ResultSet rs,
            String key
    ) throws SQLException {

        double value = rs.getDouble(key);

        return rs.wasNull()
                ? null
                : value;
    }

    private static Long nullableLong(
            ResultSet rs,
            String key
    ) throws SQLException {

        long value = rs.getLong(key);

        return rs.wasNull()
                ? null
                : value;
    }

    private static String text(
            ResultSet rs,
            String key
    ) throws SQLException {

        String value = rs.getString(key);

        return value == null
                ? ""
                : value;
    }
}