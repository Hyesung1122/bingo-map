package com.bingomap.bingo_map.review;

import java.time.LocalDate;

/**
 * 리뷰 작성/수정 요청 데이터.
 *
 * targetType : WASTE_BIN / RESTAURANT
 * targetId   : 대상 PK 또는 OSM ID
 */
public class ReviewRequestDto {

    private Long userId;

    private String targetType;
    private String targetId;

    // 기존 화면과의 호환용
    private Long restaurantId;

    private Double rating;
    private String content;
    private LocalDate visitDate;
    private String visitTimeSlot;
    private String visitPurpose;
    private Boolean recommendYn;

    public ReviewRequestDto() {
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getTargetType() {
        return targetType;
    }

    public void setTargetType(String targetType) {
        this.targetType = targetType;
    }

    public String getTargetId() {
        return targetId;
    }

    public void setTargetId(String targetId) {
        this.targetId = targetId;
    }

    public Long getRestaurantId() {
        return restaurantId;
    }

    public void setRestaurantId(Long restaurantId) {
        this.restaurantId = restaurantId;
    }

    public Double getRating() {
        return rating;
    }

    public void setRating(Double rating) {
        this.rating = rating;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public LocalDate getVisitDate() {
        return visitDate;
    }

    public void setVisitDate(LocalDate visitDate) {
        this.visitDate = visitDate;
    }

    public String getVisitTimeSlot() {
        return visitTimeSlot;
    }

    public void setVisitTimeSlot(String visitTimeSlot) {
        this.visitTimeSlot = visitTimeSlot;
    }

    public String getVisitPurpose() {
        return visitPurpose;
    }

    public void setVisitPurpose(String visitPurpose) {
        this.visitPurpose = visitPurpose;
    }

    public Boolean getRecommendYn() {
        return recommendYn;
    }

    public void setRecommendYn(Boolean recommendYn) {
        this.recommendYn = recommendYn;
    }
}