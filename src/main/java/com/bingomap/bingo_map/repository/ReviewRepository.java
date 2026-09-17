package com.bingomap.bingo_map.repository;

import com.bingomap.bingo_map.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReviewRepository extends JpaRepository<Review, Long> {

    List<Review> findAllByOrderByCreatedAtDesc();

    List<Review> findByRestaurantIdOrderByCreatedAtDesc(Long restaurantId);

    List<Review> findByUserIdOrderByCreatedAtDesc(Long userId);

    // 게시판 목록용: 키워드(리뷰 내용) 검색 + 페이징/정렬
    // 오라클이 OFFSET/FETCH 페이징 문법(ORA-00933)을 지원하지 않아 Sort 기반으로 전체 조회 후 자바에서 자른다.
    List<Review> findByContentContainingIgnoreCase(String keyword, org.springframework.data.domain.Sort sort);

    // 맛집(restaurantId)별 리뷰 개수/평균 별점 집계. 리뷰 많은 순으로 정렬.
    @org.springframework.data.jpa.repository.Query(
            "SELECT r.restaurantId AS restaurantId, COUNT(r) AS reviewCount, AVG(r.rating) AS avgRating " +
            "FROM Review r GROUP BY r.restaurantId ORDER BY COUNT(r) DESC")
    List<RestaurantReviewSummary> findRestaurantSummaries();
}
