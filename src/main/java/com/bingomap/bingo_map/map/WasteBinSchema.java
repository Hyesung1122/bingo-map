package com.bingomap.bingo_map.map;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashSet;
import java.util.Set;

/**
 * 최종 waste_bin 테이블 구조 확인용.
 *
 * 최종 구조:
 * waste_bin
 * - id
 * - osm_id
 * - name
 * - category
 * - address
 * - latitude
 * - longitude
 * - city
 * - created_at
 * - updated_at
 */
final class WasteBinSchema {

    private WasteBinSchema() {
    }

    static String idColumn(Connection connection) throws SQLException {
        Set<String> columns = columns(connection);

        if (!columns.contains("ID")) {
            throw new SQLException(
                    "WASTE_BIN 테이블에 ID 컬럼이 없습니다."
            );
        }

        validateColumns(columns);

        return "ID";
    }

    private static Set<String> columns(
            Connection connection
    ) throws SQLException {

        Set<String> columns = new HashSet<>();

        try (
                Statement statement = connection.createStatement();
                ResultSet result =
                        statement.executeQuery(
                                "SELECT * FROM WASTE_BIN WHERE 1 = 0"
                        )
        ) {

            var metadata = result.getMetaData();

            for (int i = 1;
                 i <= metadata.getColumnCount();
                 i++) {

                columns.add(
                        metadata.getColumnName(i)
                );
            }
        }

        return columns;
    }

    private static void validateColumns(
            Set<String> columns
    ) throws SQLException {

        String[] required = {
                "ID",
                "OSM_ID",
                "NAME",
                "CATEGORY",
                "ADDRESS",
                "LATITUDE",
                "LONGITUDE",
                "CITY"
        };

        for (String column : required) {

            if (!columns.contains(column)) {

                throw new SQLException(
                        "WASTE_BIN 필수 컬럼이 없습니다: "
                                + column
                );
            }
        }
    }

    /**
     * 최종 DB에서는 ID + WASTE_BIN_SEQ 구조를 사용한다.
     */
    static ImportLayout importLayout(
            Connection connection
    ) throws SQLException {

        Set<String> columns =
                columns(connection);

        validateColumns(columns);

        Set<String> sequences =
                new HashSet<>();

        try (
                Statement statement =
                        connection.createStatement();
                ResultSet result =
                        statement.executeQuery(
                                "SELECT SEQUENCE_NAME " +
                                        "FROM USER_SEQUENCES " +
                                        "WHERE SEQUENCE_NAME = 'WASTE_BIN_SEQ'"
                        )
        ) {

            while (result.next()) {
                sequences.add(
                        result.getString(1)
                );
            }
        }

        if (!sequences.contains("WASTE_BIN_SEQ")) {

            throw new SQLException(
                    "WASTE_BIN_SEQ 시퀀스가 없습니다."
            );
        }

        String dateColumns = "";
        String dateValues = "";

        if (columns.contains("CREATED_AT")) {
            dateColumns += ", CREATED_AT";
            dateValues += ", SYSTIMESTAMP";
        }

        if (columns.contains("UPDATED_AT")) {
            dateColumns += ", UPDATED_AT";
            dateValues += ", SYSTIMESTAMP";
        }

        return new ImportLayout(
                "ID",
                "WASTE_BIN_SEQ",
                dateColumns,
                dateValues
        );
    }

    record ImportLayout(
            String idColumn,
            String sequenceName,
            String dateColumns,
            String dateValues
    ) {
    }
}