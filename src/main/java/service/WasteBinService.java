package com.bingomap.bingo_map.service;

import com.bingomap.bingo_map.dto.WasteBinDto;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

/**
 * Overpass API를 직접 호출하던 방식에서, 미리 적재해둔 WASTE_BIN 테이블을 읽는 방식으로 변경.
 * 데이터 적재는 WasteBinDbLoader(1회 실행용 도구)가 담당.
 * Overpass 서버가 죽어있어도 이 서비스는 영향받지 않음.
 */
@Service
public class WasteBinService {

    private final JdbcTemplate jdbc;

    public WasteBinService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final String SQL = """
            SELECT BIN_ID, LATITUDE, LONGITUDE, NAME, CATEGORY, ADDRESS
            FROM WASTE_BIN
            WHERE CITY = ?
            ORDER BY BIN_ID
            """;

    /** 기존 호출부(BinController 등) 호환용 — 오사카 기본 조회 */
    public List<WasteBinDto> getWasteBins() {
        return getWasteBins("osaka");
    }

    /** 도시 확장용 — 예: getWasteBins("tokyo") */
    public List<WasteBinDto> getWasteBins(String city) {
        return jdbc.query(SQL, (rs, rowNum) -> read(rs), city);
    }

    private static WasteBinDto read(ResultSet rs) throws SQLException {
        return new WasteBinDto(
                rs.getLong("BIN_ID"),
                rs.getDouble("LATITUDE"),
                rs.getDouble("LONGITUDE"),
                rs.getString("NAME"),
                rs.getString("CATEGORY"),
                rs.getString("ADDRESS")
        );
    }
}
