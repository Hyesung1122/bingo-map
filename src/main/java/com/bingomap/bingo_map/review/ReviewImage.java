package com.bingomap.bingo_map.review;

import jakarta.persistence.*;

@Entity
@Table(name = "review_image")
public class ReviewImage {

    @Id
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "review_image_seq"
    )
    @SequenceGenerator(
            name = "review_image_seq",
            sequenceName = "SEQ_REVIEW_IMAGE",
            allocationSize = 1
    )
    @Column(name = "id")
    private Long reviewImageId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "review_id", nullable = false)
    private Review review;

    @Column(name = "image_url", nullable = false, length = 255)
    private String imageUrl;

    @Column(name = "sort_order")
    private Integer sortOrder;

    protected ReviewImage() {
    }

    public ReviewImage(String imageUrl, Integer sortOrder) {
        this.imageUrl = imageUrl;
        this.sortOrder = sortOrder;
    }

    public static ReviewImage upload(
            String imageUrl,
            Integer sortOrder
    ) {
        return new ReviewImage(imageUrl, sortOrder);
    }

    public Long getReviewImageId() {
        return reviewImageId;
    }

    public Review getReview() {
        return review;
    }

    public void setReview(Review review) {
        this.review = review;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public Integer getSortOrder() {
        return sortOrder;
    }
}