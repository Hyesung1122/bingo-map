package com.bingomap.bingo_map.dto;

import lombok.Getter;

/** GET /api/admin/users 응답의 각 행 */
@Getter
public class AdminUserDto {
    private final Long userId;
    private final String name;
    private final String nickname;
    private final String email;
    private final String role;
    private final String joinedAt;

    public AdminUserDto(Long userId, String name, String nickname, String email, String role, String joinedAt) {
        this.userId = userId;
        this.name = name;
        this.nickname = nickname;
        this.email = email;
        this.role = role;
        this.joinedAt = joinedAt;
    }
}