package com.bingomap.bingo_map.favorite;

import com.bingomap.bingo_map.entity.TargetType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FavoriteRepository extends JpaRepository<Favorite, Long> {

    List<Favorite> findByUserUserIdOrderByCreatedAtDesc(
            Long userId
    );

    List<Favorite> findByUserUserIdAndTargetTypeOrderByCreatedAtDesc(
            Long userId,
            TargetType targetType
    );

    boolean existsByUserUserIdAndTargetTypeAndTargetId(
            Long userId,
            TargetType targetType,
            String targetId
    );

    // 마이페이지 통계(즐겨찾기 수)에서 사용
    long countByUserUserId(Long userId);

    // FavoriteService.delete()가 삭제된 개수를 받아 == 0 으로 비교하므로 void가 아니라 long이어야 함
    long deleteByIdAndUserUserId(
            Long id,
            Long userId
    );
}