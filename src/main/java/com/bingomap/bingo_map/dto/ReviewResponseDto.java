package com.bingomap.bingo_map.dto;

import com.bingomap.bingo_map.entity.Review;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 리뷰 목록/상세 화면에 내려주는 응답 데이터.
 */
public class ReviewResponseDto {

    private Long reviewId;
    private Long userId;
    private Long restaurantId;
    private Double rating;
    private String content;
    private LocalDate visitDate;
    private String visitTimeSlot;
    private String visitPurpose;
    private Boolean recommendYn;
    private Integer helpCount;
    private LocalDateTime createdAt;
    private List<String> imageUrls;

    public ReviewResponseDto(Review review) {
        this.reviewId = review.getReviewId();
        this.userId = review.getUserId();
        this.restaurantId = review.getRestaurantId();
        this.rating = review.getRating();
        this.content = review.getContent();
        this.visitDate = review.getVisitDate();
        this.visitTimeSlot = review.getVisitTimeSlot();
        this.visitPurpose = review.getVisitPurpose();
        this.recommendYn = review.getRecommendYn();
        this.helpCount = review.getHelpCount();
        this.createdAt = review.getCreatedAt();
        this.imageUrls = review.getImages().stream()
                .map(com.bingomap.bingo_map.entity.ReviewImage::getImageUrl)
                .collect(Collectors.toList());
    }

    public Long getReviewId() { return reviewId; }
    public Long getUserId() { return userId; }
    public Long getRestaurantId() { return restaurantId; }
    public Double getRating() { return rating; }
    public String getContent() { return content; }
    public LocalDate getVisitDate() { return visitDate; }
    public String getVisitTimeSlot() { return visitTimeSlot; }
    public String getVisitPurpose() { return visitPurpose; }
    public Boolean getRecommendYn() { return recommendYn; }
    public Integer getHelpCount() { return helpCount; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public List<String> getImageUrls() { return imageUrls; }
}
