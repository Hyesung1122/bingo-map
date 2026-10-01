package com.bingomap.bingo_map.user.admin;

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
    private final boolean blocked;
    private final boolean blockedPermanently;
    private final String blockedUntil;

    public AdminUserDto(Long userId, String name, String nickname, String email, String role, String joinedAt,
                        boolean blocked, boolean blockedPermanently, String blockedUntil) {
        this.userId = userId;
        this.name = name;
        this.nickname = nickname;
        this.email = email;
        this.role = role;
        this.joinedAt = joinedAt;
        this.blocked = blocked;
        this.blockedPermanently = blockedPermanently;
        this.blockedUntil = blockedUntil;
    }
}
