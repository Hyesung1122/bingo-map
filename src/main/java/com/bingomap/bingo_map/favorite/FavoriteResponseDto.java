package com.bingomap.bingo_map.favorite;

import com.bingomap.bingo_map.entity.TargetType;

import java.time.LocalDateTime;

public record FavoriteResponseDto(
        Long id,
        TargetType targetType,
        String targetId,
        String targetName,
        String location,
        Double latitude,
        Double longitude,
        LocalDateTime createdAt
) {}
