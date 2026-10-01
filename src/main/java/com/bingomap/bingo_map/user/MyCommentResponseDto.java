package com.bingomap.bingo_map.user;

/** 마이페이지 "작성한 댓글" 탭용 DTO */
public class MyCommentResponseDto {

    private Long commentId;
    private Long postId;
    private String postTitle; // 어느 글에 단 댓글인지 (삭제된 글이면 "삭제된 글")
    private String content;
    private String createdAt; // yyyy.MM.dd
    private String linkUrl;   // /community/{postId}

    public MyCommentResponseDto(Long commentId, Long postId, String postTitle,
                                String content, String createdAt, String linkUrl) {
        this.commentId = commentId;
        this.postId = postId;
        this.postTitle = postTitle;
        this.content = content;
        this.createdAt = createdAt;
        this.linkUrl = linkUrl;
    }

    public Long getCommentId() { return commentId; }
    public Long getPostId() { return postId; }
    public String getPostTitle() { return postTitle; }
    public String getContent() { return content; }
    public String getCreatedAt() { return createdAt; }
    public String getLinkUrl() { return linkUrl; }
}