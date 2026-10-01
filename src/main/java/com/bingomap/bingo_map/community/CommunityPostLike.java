package com.bingomap.bingo_map.community;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

/**
 * [10/01 유해성] 커뮤니티 글 좋아요 (COMMUNITY_POST_LIKE). 한 회원이 한 글에 한 번만.
 */
@Entity
@Table(name = "community_post_like")
public class CommunityPostLike {

    @Id
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "community_post_like_seq"
    )
    @SequenceGenerator(
            name = "community_post_like_seq",
            sequenceName = "SEQ_COMMUNITY_POST_LIKE",
            allocationSize = 1
    )
    @Column(name = "id")
    private Long likeId;

    @Column(name = "post_id", nullable = false)
    private Long postId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    protected CommunityPostLike() {
    }

    public CommunityPostLike(Long postId, Long userId) {
        this.postId = postId;
        this.userId = userId;
        this.createdAt = LocalDateTime.now();
    }

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null) {
            this.createdAt = LocalDateTime.now();
        }
    }

    public Long getLikeId() {
        return likeId;
    }

    public Long getPostId() {
        return postId;
    }

    public Long getUserId() {
        return userId;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}
