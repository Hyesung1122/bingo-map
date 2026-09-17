package com.bingomap.bingo_map.restaurantmap;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public final class RestaurantMapModels {
    private RestaurantMapModels() {}

    // id는 RESTAURANT_ID를 문자열로 표현한 값입니다. OSM ID가 아닙니다.
    public record Place(String id, long restaurantId, String name, String category, String tags,
                        BigDecimal rating, Long reviewCount, String description, String address,
                        Double lat, Double lon, String openingHours, String phone, String priceRange,
                        String websiteUrl, String seatInfo, String reservationInfo,
                        String paymentMethods, String languages, String mainImageUrl,
                        String menuName, String menuDescription, String menuPrice, String menuImageUrl) {}

    public record Result(List<Place> places, int totalCount, int invalidCoordinateCount,
                         boolean sampleData, Instant fetchedAt, String source, String message) {}

    public record Error(String message) {}
}
