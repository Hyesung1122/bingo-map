package com.bingomap.bingo_map.routing;

import java.util.List;

/** 추가: 길찾기 요청/응답. 거리 m, 시간 초, 좌표는 GeoJSON의 [경도, 위도]. */
public final class RouteModels {
    private RouteModels() {}

    public record Request(Double startLat, Double startLon, Double endLat, Double endLon, String mode) {}
    public record Step(int type, String instruction, String roadName,
                       double distanceMeters, double durationSeconds, int startIndex, int endIndex) {}
    public record Route(String mode, double distanceMeters, double durationSeconds,
                        List<List<Double>> coordinates, List<Step> steps,
                        double startGapMeters, double endGapMeters) {}
    public record Error(String code, String message) {}

    public static class Failure extends RuntimeException {
        private static final long serialVersionUID = 1L;
        public final int status;
        public final String code;
        public Failure(int status, String code, String message) {
            super(message);
            this.status = status;
            this.code = code;
        }
    }
}
