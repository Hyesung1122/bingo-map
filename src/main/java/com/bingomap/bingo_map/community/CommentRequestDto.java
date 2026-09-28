package com.bingomap.bingo_map.community;

public class CommentRequestDto {
    private Long userId; // TODO: 로그인 연동 전까지 데모 사용자 id 사용
    private String content;

    public CommentRequestDto() {}

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
}
