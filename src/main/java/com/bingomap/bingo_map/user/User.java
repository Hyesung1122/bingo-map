package com.bingomap.bingo_map.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
public class User {

    @Id
    @GeneratedValue(
            strategy = GenerationType.SEQUENCE,
            generator = "seq_user"
    )
    @SequenceGenerator(
            name = "seq_user",
            sequenceName = "users_seq",
            allocationSize = 1
    )
    @Column(name = "id")
    private Long userId;

    @Column(name = "email", nullable = false, unique = true, length = 100)
    private String email;

    @Column(name = "password", nullable = false, length = 255)
    private String password;

    @Column(name = "name", nullable = false, length = 50)
    private String name;

    @Column(name = "nickname", length = 30)
    private String nickname;

    @Column(name = "nationality", length = 50)
    private String nationality;

    @Column(name = "sns_type", length = 20)
    private String snsType;

    @Column(name = "security_question", length = 100)
    private String securityQuestion;

    @Column(name = "security_answer", length = 255)
    private String securityAnswer;

    @Column(name = "notify_email", length = 1)
    private String notifyEmail;

    @Column(name = "location_enabled", length = 1)
    private String locationEnabled;

    @Column(name = "role", nullable = false, length = 20)
    private String role;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "blocked_until")
    private LocalDateTime blockedUntil;

    @Column(name = "blocked_permanent", nullable = false, length = 1)
    private String blockedPermanent = "N";

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();

        if (this.createdAt == null) {
            this.createdAt = now;
        }

        if (this.updatedAt == null) {
            this.updatedAt = now;
        }

        if (this.snsType == null) {
            this.snsType = "NONE";
        }

        if (this.role == null) {
            this.role = "USER";
        }

        if (this.notifyEmail == null) {
            this.notifyEmail = "Y";
        }

        if (this.locationEnabled == null) {
            this.locationEnabled = "N";
        }

        if (this.blockedPermanent == null) {
            this.blockedPermanent = "N";
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    public boolean isNotifyEmail() {
        return "Y".equals(notifyEmail);
    }

    public boolean isLocationEnabled() {
        return "Y".equals(locationEnabled);
    }

    public boolean isCurrentlyBlocked(LocalDateTime now) {
        return "Y".equals(blockedPermanent)
                || (blockedUntil != null && blockedUntil.isAfter(now));
    }

    public boolean isBlockedPermanently() {
        return "Y".equals(blockedPermanent);
    }

    public void blockUntil(LocalDateTime until) {
        this.blockedUntil = until;
        this.blockedPermanent = "N";
    }

    public void blockPermanently() {
        this.blockedUntil = null;
        this.blockedPermanent = "Y";
    }

    public void unblock() {
        this.blockedUntil = null;
        this.blockedPermanent = "N";
    }

    public User(
            String name,
            String nickname,
            String email,
            String password,
            String nationality,
            String snsType
    ) {
        this.name = name;
        this.nickname = nickname;
        this.email = email;
        this.password = password;
        this.nationality = nationality;
        this.snsType = snsType;
    }
}
