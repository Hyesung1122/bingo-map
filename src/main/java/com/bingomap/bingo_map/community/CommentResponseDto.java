package com.bingomap.bingo_map.community;

import java.time.LocalDateTime;

public class CommentResponseDto {
    private Long commentId;
    private Long postId;
    private Long userId;
    private String content;
    private LocalDateTime createdAt;

    public CommentResponseDto(CommunityComment c) {
        this.commentId = c.getCommentId();
        this.postId = c.getPostId();
        this.userId = c.getUserId();
        this.content = c.getContent();
        this.createdAt = c.getCreatedAt();
    }

    public Long getCommentId() { return commentId; }
    public Long getPostId() { return postId; }
    public Long getUserId() { return userId; }
    public String getContent() { return content; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
