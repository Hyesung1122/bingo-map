package com.bingomap.bingo_map.restaurant;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface RestaurantRepository extends JpaRepository<Restaurant, Long> {

    // RestaurantApiController 등에서 전체 조회 시 사용
    List<Restaurant> findByIsPublished(String isPublished);

    // 1. 우메다, 신사이바시, 신세카이, 난바 등
    @Query("SELECT r FROM Restaurant r " +
            "WHERE r.isPublished = 'Y' " +
            "AND (r.address LIKE %:keyword1% OR r.address LIKE %:keyword2%)")
    Page<Restaurant> findByIsPublishedAndAddressContaining(
            @Param("keyword1") String keyword1,
            @Param("keyword2") String keyword2,
            Pageable pageable
    );

    // 2. 도톤보리 통합 검색
    @Query("SELECT r FROM Restaurant r " +
            "WHERE r.isPublished = 'Y' " +
            "AND (r.address LIKE %:keyword1% " +
            "OR r.address LIKE %:keyword2% " +
            "OR r.address LIKE %:keyword3% " +
            "OR r.address LIKE %:keyword4%)")
    Page<Restaurant> findByIsPublishedAndMultipleAddress(
            @Param("keyword1") String keyword1,
            @Param("keyword2") String keyword2,
            @Param("keyword3") String keyword3,
            @Param("keyword4") String keyword4,
            Pageable pageable
    );
}