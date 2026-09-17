package com.bingomap.bingo_map.dto;

public class CommunityPostRequestDto {

    private Long userId; // TODO: 로그인 연동 전까지 데모 사용자 id 사용
    private String title;
    private String content;
    private String tags;

    public CommunityPostRequestDto() {
    }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getTags() { return tags; }
    public void setTags(String tags) { this.tags = tags; }
}
