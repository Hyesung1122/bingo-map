package com.bingomap.bingo_map.community;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * 커뮤니티 게시글에 달리는 댓글.
 * DB 테이블: TB_COMMUNITY_COMMENT
 */
@Entity
@Table(name = "TB_COMMUNITY_COMMENT")
public class CommunityComment {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "community_comment_seq")
    @SequenceGenerator(name = "community_comment_seq", sequenceName = "SEQ_COMMUNITY_COMMENT", allocationSize = 1)
    @Column(name = "COMMENT_ID")
    private Long commentId;

    @Column(name = "POST_ID", nullable = false)
    private Long postId;

    @Column(name = "USER_ID", nullable = false)
    private Long userId;

    @Column(name = "CONTENT", nullable = false, length = 1000)
    private String content;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    protected CommunityComment() {
    }

    public CommunityComment(Long postId, Long userId, String content) {
        this.postId = postId;
        this.userId = userId;
        this.content = content;
        this.createdAt = LocalDateTime.now();
    }

    public Long getCommentId() { return commentId; }
    public Long getPostId() { return postId; }
    public Long getUserId() { return userId; }
    public String getContent() { return content; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
