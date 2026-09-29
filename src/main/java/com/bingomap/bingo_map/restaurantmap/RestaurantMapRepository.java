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

    private static final String SQL = """
        SELECT
            restaurant_id,
            name,
            category,
            tags,
            rating,
            review_count,
            description,
            address,
            latitude,
            longitude,
            opening_hours,
            phone,
            price_range,
            website_url,
            seat_info,
            reservation_info,
            payment_methods,
            languages,
            main_image_url,
            menu_name,
            menu_description,
            menu_price,
            menu_image_url
        FROM restaurants
        WHERE is_published = 'Y'
        ORDER BY restaurant_id
        """;

    public List<Place> findAll() {
        return jdbc.query(SQL, (rs, rowNum) -> read(rs));
    }

    static Place read(ResultSet rs) throws SQLException {
        long restaurantId = rs.getLong("restaurant_id");

        return new Place(
                Long.toString(restaurantId),
                restaurantId,
                text(rs, "name"),
                text(rs, "category"),
                text(rs, "tags"),
                rs.getBigDecimal("rating"),
                nullableLong(rs, "review_count"),
                text(rs, "description"),
                text(rs, "address"),
                coordinate(rs, "latitude"),
                coordinate(rs, "longitude"),
                text(rs, "opening_hours"),
                text(rs, "phone"),
                text(rs, "price_range"),
                text(rs, "website_url"),
                text(rs, "seat_info"),
                text(rs, "reservation_info"),
                text(rs, "payment_methods"),
                text(rs, "languages"),
                text(rs, "main_image_url"),
                text(rs, "menu_name"),
                text(rs, "menu_description"),
                text(rs, "menu_price"),
                text(rs, "menu_image_url")
        );
    }

    static boolean hasCoordinates(Place place) {
        return place.lat() != null
                && place.lon() != null
                && Double.isFinite(place.lat())
                && Double.isFinite(place.lon())
                && Math.abs(place.lat()) <= 90
                && Math.abs(place.lon()) <= 180;
    }

    private static Double coordinate(
            ResultSet rs,
            String column
    ) throws SQLException {

        double value = rs.getDouble(column);
        return rs.wasNull() ? null : value;
    }

    private static Long nullableLong(
            ResultSet rs,
            String column
    ) throws SQLException {

        long value = rs.getLong(column);
        return rs.wasNull() ? null : value;
    }

    private static String text(
            ResultSet rs,
            String column
    ) throws SQLException {

        String value = rs.getString(column);
        return value == null ? "" : value;
    }
}