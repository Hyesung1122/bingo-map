package com.bingomap.bingo_map.favorite;

import com.bingomap.bingo_map.entity.TargetType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FavoriteRepository extends JpaRepository<Favorite, Long> {

    List<Favorite> findByUserUserIdOrderByCreatedAtDesc(
            Long userId
    );

    boolean existsByUserUserIdAndTargetTypeAndTargetId(
            Long userId,
            TargetType targetType,
            String targetId
    );

    void deleteByIdAndUserUserId(
            Long id,
            Long userId
    );
}