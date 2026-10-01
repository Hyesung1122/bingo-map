package com.bingomap.bingo_map.community;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

/**
 * [10/01 유해성] 커뮤니티 좋아요
 */
public interface CommunityPostLikeRepository extends JpaRepository<CommunityPostLike, Long> {

    long countByPostId(Long postId);

    boolean existsByPostIdAndUserId(Long postId, Long userId);

    Optional<CommunityPostLike> findByPostIdAndUserId(Long postId, Long userId);

    List<CommunityPostLike> findByPostId(Long postId);
}
