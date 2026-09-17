package com.bingomap.bingo_map.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * users 테이블과 매핑되는 Entity (팀 공용 스키마 네이밍)
 * - Oracle 11g는 IDENTITY 컬럼을 지원하지 않아 시퀀스(users_seq) 방식을 사용한다.
 *   (실제 테이블/시퀀스는 resources/sql/BinGoMap_ORACLE_query_taegun.sql 참고, ddl-auto: none 이라 직접 실행 필요)
 */
@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_user")
    @SequenceGenerator(name = "seq_user", sequenceName = "users_seq", allocationSize = 1)
    @Column(name = "id")
    private Long userId;

    @Column(name = "name", nullable = false, length = 50)
    private String name;

    @Column(name = "nickname", nullable = false, unique = true, length = 30)
    private String nickname;

    @Column(name = "email", nullable = false, unique = true, length = 100)
    private String email;

    // 간편가입(sns) 유저는 비밀번호가 없을 수 있어 nullable 허용
    @Column(name = "password", length = 255)
    private String password;

    @Column(name = "nationality", length = 50)
    private String nationality;

    // 일반가입: NONE / 간편가입: GOOGLE, APPLE, KAKAO
    @Column(name = "sns_type", length = 20)
    private String snsType;

    // USER(일반회원) / ADMIN(관리자)
    @Column(name = "role", length = 20)
    private String role;

    // 비밀번호 재설정 시 본인확인용 질문/답변(답변은 해시로 저장)
    @Column(name = "security_question", length = 100)
    private String securityQuestion;

    @Column(name = "security_answer", length = 255)
    private String securityAnswer;

    // 마이페이지 설정: 이메일 알림 받기 여부
    @Column(name = "notify_email", length = 1)
    private String notifyEmail;

    // 마이페이지 설정: 위치 정보 사용 여부
    @Column(name = "location_enabled", length = 1)
    private String locationEnabled;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
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
    }

    public boolean isNotifyEmail() {
        return "Y".equals(notifyEmail);
    }

    public boolean isLocationEnabled() {
        return "Y".equals(locationEnabled);
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    public User(String name, String nickname, String email, String password, String nationality, String snsType) {
        this.name = name;
        this.nickname = nickname;
        this.email = email;
        this.password = password;
        this.nationality = nationality;
        this.snsType = snsType;
    }
}