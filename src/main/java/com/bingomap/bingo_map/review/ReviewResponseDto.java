package com.bingomap.bingo_map.review;

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

    private String targetType;
    private String targetId;

    private Double rating;
    private String content;
    private LocalDate visitDate;
    private String visitTimeSlot;
    private String visitPurpose;
    private Boolean recommendYn;
    private Integer helpCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private List<String> imageUrls;

    public ReviewResponseDto(Review review) {
        this.reviewId = review.getReviewId();
        this.userId = review.getUserId();

        this.targetType = review.getTargetType();
        this.targetId = review.getTargetId();

        this.rating = review.getRating();
        this.content = review.getContent();
        this.visitDate = review.getVisitDate();
        this.visitTimeSlot = review.getVisitTimeSlot();
        this.visitPurpose = review.getVisitPurpose();
        this.recommendYn = review.getRecommendYn();
        this.helpCount = review.getHelpCount();
        this.createdAt = review.getCreatedAt();
        this.updatedAt = review.getUpdatedAt();

        this.imageUrls = review.getImages()
                .stream()
                .map(ReviewImage::getImageUrl)
                .collect(Collectors.toList());
    }

    public Long getReviewId() {
        return reviewId;
    }

    public Long getUserId() {
        return userId;
    }

    public String getTargetType() {
        return targetType;
    }

    public String getTargetId() {
        return targetId;
    }

    public Double getRating() {
        return rating;
    }

    public String getContent() {
        return content;
    }

    public LocalDate getVisitDate() {
        return visitDate;
    }

    public String getVisitTimeSlot() {
        return visitTimeSlot;
    }

    public String getVisitPurpose() {
        return visitPurpose;
    }

    public Boolean getRecommendYn() {
        return recommendYn;
    }

    public Integer getHelpCount() {
        return helpCount;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public List<String> getImageUrls() {
        return imageUrls;
    }
}