package com.bingomap.bingo_map.review;

import jakarta.persistence.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "reviews")
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "review_seq")
    @SequenceGenerator(
            name = "review_seq",
            sequenceName = "SEQ_REVIEW",
            allocationSize = 1
    )
    @Column(name = "id")
    private Long reviewId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "target_type", nullable = false, length = 20)
    private String targetType;

    @Column(name = "target_id", nullable = false, length = 100)
    private String targetId;

    //0929 kdk 스케일 수정
    @Column(
            name = "rating",
            nullable = false
    )
    private Double rating;

//    @Column(name = "rating", nullable = false, precision = 2, scale = 1)
//    private Double rating;

    @Column(name = "content", length = 2000)
    private String content;

    @Column(name = "visit_date")
    private LocalDate visitDate;

    @Column(name = "visit_time_slot", length = 20)
    private String visitTimeSlot;

    @Column(name = "visit_purpose", length = 20)
    private String visitPurpose;

    @Column(name = "recommend_yn")
    private Integer recommendYn;

    @Column(name = "help_count")
    private Integer helpCount = 0;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @OneToMany(
            mappedBy = "review",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private List<ReviewImage> images = new ArrayList<>();

    protected Review() {
    }

    public Review(
            Long userId,
            String targetType,
            String targetId,
            Double rating,
            String content,
            LocalDate visitDate,
            String visitTimeSlot,
            String visitPurpose,
            Boolean recommendYn
    ) {
        this.userId = userId;
        this.targetType = targetType;
        this.targetId = targetId;
        this.rating = rating;
        this.content = content;
        this.visitDate = visitDate;
        this.visitTimeSlot = visitTimeSlot;
        this.visitPurpose = visitPurpose;
        this.recommendYn = toRecommendValue(recommendYn);
        this.helpCount = 0;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public void edit(
            Double rating,
            String content,
            LocalDate visitDate,
            String visitTimeSlot,
            String visitPurpose,
            Boolean recommendYn
    ) {
        this.rating = rating;
        this.content = content;
        this.visitDate = visitDate;
        this.visitTimeSlot = visitTimeSlot;
        this.visitPurpose = visitPurpose;
        this.recommendYn = toRecommendValue(recommendYn);
        this.updatedAt = LocalDateTime.now();
    }

    public void markHelpful() {
        this.helpCount =
                (this.helpCount == null ? 0 : this.helpCount) + 1;

        this.updatedAt = LocalDateTime.now();
    }

    public void addImage(ReviewImage image) {
        images.add(image);
        image.setReview(this);
    }

    private Integer toRecommendValue(Boolean value) {
        if (value == null) {
            return null;
        }

        return value ? 1 : 0;
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

    public Integer getRecommendYnValue() {
        return recommendYn;
    }

    public Boolean getRecommendYn() {
        if (recommendYn == null) {
            return null;
        }

        return recommendYn == 1;
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

    public List<ReviewImage> getImages() {
        return images;
    }
}