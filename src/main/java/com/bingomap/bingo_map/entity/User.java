package com.bingomap.bingo_map.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * users 테이블과 매핑되는 Entity
 * - 실제 DDL: BinGoMap_ORACLE_query_태건.txt (테이블명 users, 시퀀스 users_seq)
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

    @Column(name = "NAME", nullable = false, length = 50)
    private String name;

    @Column(name = "NICKNAME", nullable = false, unique = true, length = 30)
    private String nickname;

    @Column(name = "EMAIL", nullable = false, unique = true, length = 100)
    private String email;

    // 간편가입(sns) 유저는 비밀번호가 없을 수 있어 nullable 허용
    @Column(name = "PASSWORD", length = 255)
    private String password;

    @Column(name = "NATIONALITY", length = 50)
    private String nationality;

    // 일반가입: NONE / 간편가입: GOOGLE, APPLE, KAKAO
    @Column(name = "SNS_TYPE", length = 20)
    private String snsType;

    // USER(일반회원) / ADMIN(관리자)
    @Column(name = "ROLE", length = 10)
    private String role;

    // 비밀번호 재설정 시 본인확인용 질문/답변(답변은 해시로 저장)
    @Column(name = "SECURITY_QUESTION", length = 100)
    private String securityQuestion;

    @Column(name = "SECURITY_ANSWER", length = 255)
    private String securityAnswer;

    @Column(name = "CREATED_AT", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.snsType == null) {
            this.snsType = "NONE";
        }
        if (this.role == null) {
            this.role = "USER";
        }
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