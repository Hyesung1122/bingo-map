package com.bingomap.bingo_map.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * TB_USER 테이블과 매핑되는 Entity
 * - Oracle 11g는 IDENTITY 컬럼을 지원하지 않아 시퀀스(SEQ_TB_USER) 방식을 사용한다.
 *   (실제 테이블/시퀀스는 resources/sql/tb_user_ddl.sql 참고, ddl-auto: none 이라 직접 실행 필요)
 */
@Entity
@Table(name = "TB_USER")
@Getter
@Setter
@NoArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq_user")
    @SequenceGenerator(name = "seq_user", sequenceName = "SEQ_TB_USER", allocationSize = 1)
    @Column(name = "USER_ID")
    private Long userId;

    @Column(name = "NAME", nullable = false, length = 50)
    private String name;

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

    @Column(name = "CREATED_AT", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        if (this.snsType == null) {
            this.snsType = "NONE";
        }
    }

    public User(String name, String email, String password, String nationality, String snsType) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.nationality = nationality;
        this.snsType = snsType;
    }
}