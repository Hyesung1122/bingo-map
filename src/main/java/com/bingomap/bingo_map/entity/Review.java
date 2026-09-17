package com.bingomap.bingo_map.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 맛집에 대한 회원 리뷰(별점·방문정보·사진 포함)를 표현하는 엔티티.
 * DB 테이블: TB_REVIEW
 */
@Entity
@Table(name = "TB_REVIEW")
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "review_seq")
    @SequenceGenerator(name = "review_seq", sequenceName = "SEQ_REVIEW", allocationSize = 1)
    @Column(name = "REVIEW_ID")
    private Long reviewId;

    @Column(name = "USER_ID", nullable = false)
    private Long userId;

    @Column(name = "RESTAURANT_ID", nullable = false)
    private Long restaurantId;

    @Column(name = "RATING", nullable = false)
    private Double rating;

    @Column(name = "CONTENT", nullable = false, length = 2000)
    private String content;

    @Column(name = "VISIT_DATE")
    private LocalDate visitDate;

    @Column(name = "VISIT_TIME_SLOT", length = 20)
    private String visitTimeSlot;

    @Column(name = "VISIT_PURPOSE", length = 20)
    private String visitPurpose;

    @Column(name = "RECOMMEND_YN")
    private Boolean recommendYn;

    @Column(name = "HELP_COUNT", nullable = false)
    private Integer helpCount = 0;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "review", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ReviewImage> images = new ArrayList<>();

    protected Review() {
        // JPA 기본 생성자
    }

    public Review(Long userId, Long restaurantId, Double rating, String content,
                  LocalDate visitDate, String visitTimeSlot, String visitPurpose,
                  Boolean recommendYn) {
        this.userId = userId;
        this.restaurantId = restaurantId;
        this.rating = rating;
        this.content = content;
        this.visitDate = visitDate;
        this.visitTimeSlot = visitTimeSlot;
        this.visitPurpose = visitPurpose;
        this.recommendYn = recommendYn;
        this.helpCount = 0;
        this.createdAt = LocalDateTime.now();
    }

    // ── 도메인 메서드 (클래스 다이어그램 기준: create/edit/delete/markHelpful) ──

    /** 리뷰 내용을 수정한다. */
    public void edit(Double rating, String content, LocalDate visitDate,
                      String visitTimeSlot, String visitPurpose, Boolean recommendYn) {
        this.rating = rating;
        this.content = content;
        this.visitDate = visitDate;
        this.visitTimeSlot = visitTimeSlot;
        this.visitPurpose = visitPurpose;
        this.recommendYn = recommendYn;
}

    /** '도움이 돼요' 카운트를 1 증가시킨다. */
    public void markHelpful() {
        this.helpCount = (this.helpCount == null ? 0 : this.helpCount) + 1;
    }

    public void addImage(ReviewImage image) {
        images.add(image);
        image.setReview(this);
    }

    // ── getters ──

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
    public List<ReviewImage> getImages() { return images; }
}
