package com.bingomap.bingo_map.repository;

/**
 * 맛집(restaurantId)별 리뷰 개수/평균 별점 집계 결과를 받기 위한 프로젝션.
 */
public interface RestaurantReviewSummary {
    Long getRestaurantId();
    Long getReviewCount();
    Double getAvgRating();
}
