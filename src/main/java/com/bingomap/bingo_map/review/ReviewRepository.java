package com.bingomap.bingo_map.review;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ReviewRepository extends JpaRepository<Review, Long> {

    // 전체 리뷰 최신순
    List<Review> findAllByOrderByCreatedAtDesc();

    // 특정 대상의 리뷰
    List<Review> findByTargetTypeAndTargetIdOrderByCreatedAtDesc(
            String targetType,
            String targetId
    );

    // 특정 사용자가 작성한 리뷰
    List<Review> findByUserIdOrderByCreatedAtDesc(
            Long userId
    );

    // 마이페이지 통계: 내가 쓴 리뷰 수 / 받은 '도움이 돼요' 합계
    long countByUserId(Long userId);

    @Query("select coalesce(sum(r.helpCount), 0) from Review r where r.userId = :userId")
    long sumHelpCountByUserId(@Param("userId") Long userId);

    // 리뷰 내용 검색
    List<Review> findByContentContainingIgnoreCase(
            String keyword,
            org.springframework.data.domain.Sort sort
    );
}