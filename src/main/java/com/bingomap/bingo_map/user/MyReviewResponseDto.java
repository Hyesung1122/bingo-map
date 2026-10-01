package com.bingomap.bingo_map.user;

import java.time.LocalDateTime;

/** 마이페이지 "내가 쓴 리뷰" 탭에서 내려주는 리뷰 요약 DTO */
public class MyReviewResponseDto {

    private Long reviewId;
    private Long restaurantId;
    private String restaurantName;
    private Double rating;
    private String content;
    private String createdAt; // yyyy.MM.dd 형태로 포맷
    private Integer helpCount;
    private String thumbnailUrl; // 첫 번째 이미지, 없으면 null
    private String linkUrl;      // 카드를 눌렀을 때 이동할 리뷰 상세 주소

    public MyReviewResponseDto(Long reviewId, Long restaurantId, String restaurantName, Double rating,
                               String content, String createdAt, Integer helpCount, String thumbnailUrl, String linkUrl) {
        this.reviewId = reviewId;
        this.restaurantId = restaurantId;
        this.restaurantName = restaurantName;
        this.rating = rating;
        this.content = content;
        this.createdAt = createdAt;
        this.helpCount = helpCount;
        this.thumbnailUrl = thumbnailUrl;
        this.linkUrl = linkUrl;
    }

    public Long getReviewId() { return reviewId; }
    public Long getRestaurantId() { return restaurantId; }
    public String getRestaurantName() { return restaurantName; }
    public Double getRating() { return rating; }
    public String getContent() { return content; }
    public String getCreatedAt() { return createdAt; }
    public Integer getHelpCount() { return helpCount; }
    public String getThumbnailUrl() { return thumbnailUrl; }
    public String getLinkUrl() { return linkUrl; }
}