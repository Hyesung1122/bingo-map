package com.bingomap.bingo_map.map;

import org.springframework.jdbc.core.ConnectionCallback;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/** 지도에서는 Oracle만 조회합니다. Overpass 호출은 수동 적재 도구가 담당합니다. */
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
        String cityCode = city == null || city.isBlank()
                ? "osaka" : city.trim().toLowerCase(Locale.ROOT);

        return jdbc.execute((ConnectionCallback<List<WasteBinDto>>) connection -> {
            // 수정: ID라고 단정하지 않고 실제 DB의 BIN_ID / ID를 확인합니다.
            String idColumn = WasteBinSchema.idColumn(connection);
            String sql = "SELECT " + idColumn + " AS MAP_ID, "
                    + "LATITUDE, LONGITUDE, NAME, CATEGORY, ADDRESS "
                    + "FROM WASTE_BIN WHERE CITY = ? ORDER BY " + idColumn;

            List<WasteBinDto> bins = new ArrayList<>();
            try (PreparedStatement statement = connection.prepareStatement(sql)) {
                statement.setString(1, cityCode);
                try (ResultSet result = statement.executeQuery()) {
                    while (result.next()) {
                        bins.add(new WasteBinDto(result.getLong("MAP_ID"),
                                result.getDouble("LATITUDE"), result.getDouble("LONGITUDE"),
                                result.getString("NAME"), result.getString("CATEGORY"),
                                result.getString("ADDRESS")));
                    }
                }
            }
            // JSON은 기존과 동일한 id/lat/lon/name/category/address 배열입니다.
            // SQL 실패는 숨기지 않습니다. 기존 BinController가 503을 반환합니다.
            return bins;
        });
    }
}
