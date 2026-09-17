package com.bingomap.bingo_map.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * 자유게시판(커뮤니티) 글을 표현하는 엔티티.
 * DB 테이블: TB_COMMUNITY_POST
 */
@Entity
@Table(name = "TB_COMMUNITY_POST")
public class CommunityPost {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "community_post_seq")
    @SequenceGenerator(name = "community_post_seq", sequenceName = "SEQ_COMMUNITY_POST", allocationSize = 1)
    @Column(name = "POST_ID")
    private Long postId;

    @Column(name = "USER_ID", nullable = false)
    private Long userId;

    @Column(name = "TITLE", nullable = false, length = 200)
    private String title;

    @Column(name = "CONTENT", nullable = false, length = 4000)
    private String content;

    /** 태그(콤마로 구분된 문자열). 예: "쌀국수,짜조,베트남" */
    @Column(name = "TAGS", length = 200)
    private String tags;

    @Column(name = "VIEW_COUNT", nullable = false)
    private Integer viewCount = 0;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "UPDATED_AT")
    private LocalDateTime updatedAt;

    protected CommunityPost() {
        // JPA 기본 생성자
    }

    public CommunityPost(Long userId, String title, String content, String tags) {
        this.userId = userId;
        this.title = title;
        this.content = content;
        this.tags = tags;
        this.viewCount = 0;
        this.createdAt = LocalDateTime.now();
    }

    /** 글 수정. */
    public void edit(String title, String content, String tags) {
        this.title = title;
        this.content = content;
        this.tags = tags;
        this.updatedAt = LocalDateTime.now();
    }

    /** 조회수 1 증가. */
    public void increaseViewCount() {
        this.viewCount = (this.viewCount == null ? 0 : this.viewCount) + 1;
    }

    public Long getPostId() { return postId; }
    public Long getUserId() { return userId; }
    public String getTitle() { return title; }
    public String getContent() { return content; }
    public String getTags() { return tags; }
    public Integer getViewCount() { return viewCount; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
