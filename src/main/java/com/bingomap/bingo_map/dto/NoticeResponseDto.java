package com.bingomap.bingo_map.dto;

import lombok.Getter;

/** 공지사항 조회 응답 (목록/상세 공용) */
@Getter
public class NoticeResponseDto {
    private final Long noticeId;
    private final String title;
    private final String content;
    private final String createdAt;
    private final String updatedAt;

    public NoticeResponseDto(Long noticeId, String title, String content, String createdAt, String updatedAt) {
        this.noticeId = noticeId;
        this.title = title;
        this.content = content;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
}