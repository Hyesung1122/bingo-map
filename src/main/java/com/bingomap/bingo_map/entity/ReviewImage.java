package com.bingomap.bingo_map.entity;

import jakarta.persistence.*;

/**
 * 리뷰에 첨부된 이미지(최대 5장)를 관리하는 엔티티.
 * DB 테이블: TB_REVIEW_IMAGE
 */
@Entity
@Table(name = "TB_REVIEW_IMAGE")
public class ReviewImage {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "review_image_seq")
    @SequenceGenerator(name = "review_image_seq", sequenceName = "SEQ_REVIEW_IMAGE", allocationSize = 1)
    @Column(name = "REVIEW_IMAGE_ID")
    private Long reviewImageId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "REVIEW_ID", nullable = false)
    private Review review;

    @Column(name = "IMAGE_URL", nullable = false, length = 255)
    private String imageUrl;

    @Column(name = "SORT_ORDER")
    private Integer sortOrder;

    protected ReviewImage() {
        // JPA 기본 생성자
    }

    public ReviewImage(String imageUrl, Integer sortOrder) {
        this.imageUrl = imageUrl;
        this.sortOrder = sortOrder;
    }

    /** 새 이미지를 업로드(등록)한다. 실제 파일 저장은 서비스 계층에서 처리한다. */
    public static ReviewImage upload(String imageUrl, Integer sortOrder) {
        return new ReviewImage(imageUrl, sortOrder);
    }

    public Long getReviewImageId() { return reviewImageId; }
    public Review getReview() { return review; }
    public void setReview(Review review) { this.review = review; }
    public String getImageUrl() { return imageUrl; }
    public Integer getSortOrder() { return sortOrder; }
}
