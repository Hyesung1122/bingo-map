package com.bingomap.bingo_map.community;

import java.time.LocalDateTime;

public class CommentResponseDto {
    private Long commentId;
    private Long postId;
    private Long userId;
    private String content;
    private LocalDateTime createdAt;
    private String authorName;   // [09/30 유해성] 작성자 닉네임(없으면 이름)
    private boolean authorAdmin; // [10/01 유해성] 관리자 댓글이면 배지 표시

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
    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }
    public boolean isAuthorAdmin() { return authorAdmin; }
    public void setAuthorAdmin(boolean authorAdmin) { this.authorAdmin = authorAdmin; }
}
