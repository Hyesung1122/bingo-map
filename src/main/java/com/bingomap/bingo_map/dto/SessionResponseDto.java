package com.bingomap.bingo_map.dto;

import lombok.Getter;

/** /api/session 응답용 DTO */
@Getter
public class SessionResponseDto {
    private final boolean loggedIn;
    private final String name;
    private final String role;

    public SessionResponseDto(boolean loggedIn, String name, String role) {
        this.loggedIn = loggedIn;
        this.name = name;
        this.role = role;
    }
}