package com.bingomap.bingo_map.map;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Locale;

@Service
public class WasteBinService {

    private final JdbcTemplate jdbc;

    public WasteBinService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<WasteBinDto> getWasteBins() {
        return getWasteBins("osaka");
    }

    public List<WasteBinDto> getWasteBins(String city) {

        String cityCode =
                city == null || city.isBlank()
                        ? "osaka"
                        : city.trim().toLowerCase(Locale.ROOT);

        String sql = """
                SELECT
                    id,
                    osm_id,
                    latitude,
                    longitude,
                    name,
                    category,
                    address
                FROM waste_bin
                WHERE city = ?
                ORDER BY id
                """;

        return jdbc.query(
                sql,
                (rs, rowNum) ->
                        new WasteBinDto(
                                rs.getLong("id"),
                                rs.getLong("osm_id"),
                                rs.getDouble("latitude"),
                                rs.getDouble("longitude"),
                                rs.getString("name"),
                                rs.getString("category"),
                                rs.getString("address")
                        ),
                cityCode
        );
    }
}