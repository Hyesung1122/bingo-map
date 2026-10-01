package com.bingomap.bingo_map.user;

/** 마이페이지 "작성한 게시글" 탭용 DTO */
public class MyPostResponseDto {

    private Long postId;
    private String title;
    private String contentPreview; // 목록에 보여줄 용도로 앞부분만 잘라낸 본문
    private Integer viewCount;
    private String createdAt; // yyyy.MM.dd
    private String linkUrl;   // /community/{id}

    public MyPostResponseDto(Long postId, String title, String contentPreview,
                             Integer viewCount, String createdAt, String linkUrl) {
        this.postId = postId;
        this.title = title;
        this.contentPreview = contentPreview;
        this.viewCount = viewCount;
        this.createdAt = createdAt;
        this.linkUrl = linkUrl;
    }

    public Long getPostId() { return postId; }
    public String getTitle() { return title; }
    public String getContentPreview() { return contentPreview; }
    public Integer getViewCount() { return viewCount; }
    public String getCreatedAt() { return createdAt; }
    public String getLinkUrl() { return linkUrl; }
}