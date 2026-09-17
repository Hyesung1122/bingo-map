package com.bingomap.bingo_map.repository;

import com.bingomap.bingo_map.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

/**
 * JpaRepository<User, Long> 을 상속하는 순간
 * save(), findById(), findAll(), delete() 같은 기본 CRUD가
 * application.yaml에 설정된 Oracle DB(TB_USER 테이블)를 대상으로 자동 구현된다.
 * 우리가 직접 SQL을 짜지 않아도 Hibernate가 알아서 변환해준다.
 */
public interface UserRepository extends JpaRepository<User, Long> {

    // 이메일로 회원 조회 (로그인, 중복가입 체크에 사용)
    Optional<User> findByEmail(String email);

    // 이메일 중복 여부 체크 (회원가입 검증에 사용)
    boolean existsByEmail(String email);

    // 닉네임 중복 여부 체크 (회원가입 검증에 사용)
    boolean existsByNickname(String nickname);
}