package com.bingomap.bingo_map.map;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashSet;
import java.util.Set;

/** 집/학원의 기존 테이블을 변경하지 않고 실제 컬럼 이름만 확인합니다. */
final class WasteBinSchema {
    private WasteBinSchema() {}

    static String idColumn(Connection connection) throws SQLException {
        return idColumn(columns(connection));
    }

    private static Set<String> columns(Connection connection) throws SQLException {
        Set<String> columns = new HashSet<>();
        // 데이터는 가져오지 않습니다. 현재 접속에서 보이는 WASTE_BIN의 구조만 읽습니다.
        try (Statement statement = connection.createStatement();
             ResultSet result = statement.executeQuery("SELECT * FROM WASTE_BIN WHERE 1 = 0")) {
            ResultSetMetaData metadata = result.getMetaData();
            for (int i = 1; i <= metadata.getColumnCount(); i++) {
                columns.add(metadata.getColumnName(i));
            }
        }
        return columns;
    }

    private static String idColumn(Set<String> columns) throws SQLException {
        boolean binId = columns.contains("BIN_ID");
        boolean id = columns.contains("ID");
        if (binId == id) {
            throw new SQLException("WASTE_BIN에는 BIN_ID 또는 ID 중 한 컬럼만 있어야 합니다. "
                    + "sql/01_check_home_db.sql로 실제 구조를 확인하세요.");
        }
        for (String required : Set.of("OSM_ID", "NAME", "CATEGORY", "ADDRESS",
                "LATITUDE", "LONGITUDE", "CITY")) {
            if (!columns.contains(required)) {
                throw new SQLException("WASTE_BIN 필수 컬럼이 없습니다: " + required);
            }
        }
        // SQL에 넣는 이름은 이 두 상수로만 제한합니다. 외부 입력을 SQL에 붙이지 않습니다.
        return binId ? "BIN_ID" : "ID";
    }

    /** 기존 집/학원 시퀀스를 그대로 사용하고, 존재하는 날짜 컬럼만 입력합니다. */
    static ImportLayout importLayout(Connection connection) throws SQLException {
        Set<String> columns = columns(connection);
        String id = idColumn(columns);
        Set<String> sequences = new HashSet<>();
        try (Statement statement = connection.createStatement();
             ResultSet result = statement.executeQuery("SELECT SEQUENCE_NAME FROM USER_SEQUENCES "
                     + "WHERE SEQUENCE_NAME IN ('SEQ_WASTE_BIN', 'WASTE_BIN_SEQ')")) {
            while (result.next()) sequences.add(result.getString(1));
        }
        // 집의 ID 구조: WASTE_BIN_SEQ / 기존 학원의 BIN_ID 구조: SEQ_WASTE_BIN.
        String preferred = "ID".equals(id) ? "WASTE_BIN_SEQ" : "SEQ_WASTE_BIN";
        String alternate = "ID".equals(id) ? "SEQ_WASTE_BIN" : "WASTE_BIN_SEQ";
        String sequence = sequences.contains(preferred) ? preferred
                : sequences.contains(alternate) ? alternate : null;
        if (sequence == null) {
            throw new SQLException("현재 사용자에 WASTE_BIN_SEQ 또는 SEQ_WASTE_BIN이 없습니다. "
                    + "01_check_home_db.sql로 접속 계정과 시퀀스를 확인하세요.");
        }
        String dateColumns = "";
        String dateValues = "";
        for (String column : new String[]{"CREATED_AT", "UPDATED_AT"}) {
            if (columns.contains(column)) {
                dateColumns += ", " + column;
                dateValues += ", SYSTIMESTAMP";
            }
        }
        return new ImportLayout(id, sequence, dateColumns, dateValues);
    }

    record ImportLayout(String idColumn, String sequenceName, String dateColumns, String dateValues) {}
}
