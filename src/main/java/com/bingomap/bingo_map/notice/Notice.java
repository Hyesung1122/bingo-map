package com.bingomap.bingo_map.notice;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "notices")
@Getter
@Setter
@NoArgsConstructor
public class Notice {

    @Id
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "seq_notice"
    )
    @SequenceGenerator(
            name = "seq_notice",
            sequenceName = "notices_seq",
            allocationSize = 1
    )
    @Column(name = "id")
    private Long noticeId;

    @Column(name = "author_id", nullable = false)
    private Long authorId;

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Lob
    @Column(name = "content", nullable = false)
    private String content;

    @Column(name = "view_count")
    private Integer viewCount = 0;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public Notice(
            Long authorId,
            String title,
            String content
    ) {
        this.authorId = authorId;
        this.title = title;
        this.content = content;
        this.viewCount = 0;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public void increaseViewCount() {
        this.viewCount =
                (this.viewCount == null ? 0 : this.viewCount) + 1;

        this.updatedAt = LocalDateTime.now();
    }

    @PrePersist
    protected void onCreate() {

        if (this.createdAt == null) {
            this.createdAt = LocalDateTime.now();
        }

        if (this.updatedAt == null) {
            this.updatedAt = LocalDateTime.now();
        }

        if (this.viewCount == null) {
            this.viewCount = 0;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}