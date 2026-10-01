package com.bingomap.bingo_map.community;

public class CommunityPostRequestDto {

    private Long userId;
    private String title;
    private String content;
    private String tags;
    private String category;          // [10/01 유해성] 말머리: 자유 / 질문 / 꿀팁 / 요청 / 공지(관리자만)
    private Boolean privateRequest;   // [10/01 유해성] 요청 글 비공개 여부

    public CommunityPostRequestDto() {
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public Boolean getPrivateRequest() {
        return privateRequest;
    }

    public void setPrivateRequest(Boolean privateRequest) {
        this.privateRequest = privateRequest;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getTags() {
        return tags;
    }

    public void setTags(String tags) {
        this.tags = tags;
    }
}