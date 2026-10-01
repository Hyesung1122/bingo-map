package com.bingomap.bingo_map.notification;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
public class Notification {

    public static final String TYPE_NOTICE = "NOTICE";
    public static final String TYPE_COMMENT = "COMMENT";
    public static final String TYPE_REVIEW = "REVIEW";
    public static final String TYPE_REPORT = "REPORT";

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_notification")
    @SequenceGenerator(name = "seq_notification", sequenceName = "notifications_seq", allocationSize = 1)
    @Column(name = "id")
    private Long id;

    @Column(name = "user_id", nullable = false)
    private Long userId;

    @Column(name = "noti_type", length = 20, nullable = false)
    private String type;

    @Column(name = "message", length = 300, nullable = false)
    private String message;

    @Column(name = "link_url", length = 300)
    private String linkUrl;

    @Column(name = "is_read", length = 1, nullable = false)
    private String isRead = "N";

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    protected Notification() {
    }

    public Notification(Long userId, String type, String message, String linkUrl) {
        this.userId = userId;
        this.type = type;
        this.message = message;
        this.linkUrl = linkUrl;
        this.isRead = "N";
        this.createdAt = LocalDateTime.now();
    }

    public void markRead() {
        this.isRead = "Y";
    }

    public Long getId() { return id; }
    public Long getUserId() { return userId; }
    public String getType() { return type; }
    public String getMessage() { return message; }
    public String getLinkUrl() { return linkUrl; }
    public boolean isRead() { return "Y".equals(isRead); }
    public LocalDateTime getCreatedAt() { return createdAt; }
}