package com.bingomap.bingo_map.community;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "community_post")
@Getter
@Setter
@NoArgsConstructor
public class CommunityPost {

    @Id
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "community_post_seq"
    )
    @SequenceGenerator(
            name = "community_post_seq",
            sequenceName = "SEQ_COMMUNITY_POST",
            allocationSize = 1
    )
    @Column(name = "id")
    private Long postId;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Lob
    @Column(name = "content", nullable = false)
    private String content;

    @Column(name = "tags", length = 200)
    private String tags;

    @Column(name = "view_count")
    private Integer viewCount = 0;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public CommunityPost(
            Long userId,
            String title,
            String content,
            String tags
    ) {
        this.userId = userId;
        this.title = title;
        this.content = content;
        this.tags = tags;
        this.viewCount = 0;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public void edit(
            String title,
            String content,
            String tags
    ) {
        this.title = title;
        this.content = content;
        this.tags = tags;
        this.updatedAt = LocalDateTime.now();
    }

    public void increaseViewCount() {
        if (this.viewCount == null) {
            this.viewCount = 0;
        }

        this.viewCount++;
    }

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();

        if (this.viewCount == null) {
            this.viewCount = 0;
        }

        if (this.createdAt == null) {
            this.createdAt = now;
        }

        if (this.updatedAt == null) {
            this.updatedAt = now;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}