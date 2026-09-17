package com.bingomap.bingo_map.dto;

import java.time.LocalDate;

/**
 * 리뷰 작성/수정 화면에서 넘어오는 요청 데이터.
 */
public class ReviewRequestDto {

    private Long userId;          // TODO: 로그인 기능 연동 전까지는 데모 사용자 id 사용
    private Long restaurantId;
    private Double rating;
    private String content;
    private LocalDate visitDate;
    private String visitTimeSlot;
    private String visitPurpose;
    private Boolean recommendYn;

    public ReviewRequestDto() {
    }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public Long getRestaurantId() { return restaurantId; }
    public void setRestaurantId(Long restaurantId) { this.restaurantId = restaurantId; }

    public Double getRating() { return rating; }
    public void setRating(Double rating) { this.rating = rating; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public LocalDate getVisitDate() { return visitDate; }
    public void setVisitDate(LocalDate visitDate) { this.visitDate = visitDate; }

    public String getVisitTimeSlot() { return visitTimeSlot; }
    public void setVisitTimeSlot(String visitTimeSlot) { this.visitTimeSlot = visitTimeSlot; }

    public String getVisitPurpose() { return visitPurpose; }
    public void setVisitPurpose(String visitPurpose) { this.visitPurpose = visitPurpose; }

    public Boolean getRecommendYn() { return recommendYn; }
    public void setRecommendYn(Boolean recommendYn) { this.recommendYn = recommendYn; }
}
