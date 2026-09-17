package com.bingomap.bingo_map.dto;

import lombok.Getter;

/** GET /api/mypage/me 응답용 DTO */
@Getter
public class MyPageResponseDto {
    private final String name;
    private final String nickname;
    private final String email;
    private final String nationality;
    private final String joinedAt; // yyyy.MM.dd 형태로 포맷된 가입일
    private final String role;

    public MyPageResponseDto(String name, String nickname, String email, String nationality, String joinedAt, String role) {
        this.name = name;
        this.nickname = nickname;
        this.email = email;
        this.nationality = nationality;
        this.joinedAt = joinedAt;
        this.role = role;
    }
}