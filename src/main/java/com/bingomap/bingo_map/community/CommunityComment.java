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

@Entity
@Table(name = "community_comment")
public class CommunityComment {

    @Id
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "community_comment_seq"
    )
    @SequenceGenerator(
            name = "community_comment_seq",
            sequenceName = "SEQ_COMMUNITY_COMMENT",
            allocationSize = 1
    )
    @Column(name = "id")
    private Long commentId;

    @Column(name = "post_id", nullable = false)
    private Long postId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "content", nullable = false, length = 1000)
    private String content;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    protected CommunityComment() {
    }

    public CommunityComment(
            Long postId,
            Long userId,
            String content
    ) {
        this.postId = postId;
        this.userId = userId;
        this.content = content;
        this.createdAt = LocalDateTime.now();
    }

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null) {
            this.createdAt = LocalDateTime.now();
        }
    }

    public Long getCommentId() {
        return commentId;
    }

    public Long getPostId() {
        return postId;
    }

    public Long getUserId() {
        return userId;
    }

    public String getContent() {
        return content;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}