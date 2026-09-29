package com.bingomap.bingo_map.notice;

import lombok.Getter;

@Getter
public class NoticeResponseDto {

    private final Long noticeId;
    private final Long authorId;
    private final String title;
    private final String content;
    private final Integer viewCount;
    private final String createdAt;
    private final String updatedAt;

    public NoticeResponseDto(
            Long noticeId,
            Long authorId,
            String title,
            String content,
            Integer viewCount,
            String createdAt,
            String updatedAt
    ) {
        this.noticeId = noticeId;
        this.authorId = authorId;
        this.title = title;
        this.content = content;
        this.viewCount = viewCount;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }
}