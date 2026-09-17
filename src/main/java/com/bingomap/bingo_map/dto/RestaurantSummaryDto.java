package com.bingomap.bingo_map.dto;

/**
 * 리뷰 목록(카드형) 화면에서 맛집 하나당 보여줄 요약 정보.
 */
public class RestaurantSummaryDto {

    private Long restaurantId;
    private Long reviewCount;
    private Double avgRating;
    private String previewContent;
    private String thumbnailUrl;

    public RestaurantSummaryDto(Long restaurantId, Long reviewCount, Double avgRating,
                                 String previewContent, String thumbnailUrl) {
        this.restaurantId = restaurantId;
        this.reviewCount = reviewCount;
        this.avgRating = avgRating;
        this.previewContent = previewContent;
        this.thumbnailUrl = thumbnailUrl;
    }

    public Long getRestaurantId() { return restaurantId; }
    public Long getReviewCount() { return reviewCount; }
    public Double getAvgRating() { return avgRating; }
    public String getPreviewContent() { return previewContent; }
    public String getThumbnailUrl() { return thumbnailUrl; }
}
