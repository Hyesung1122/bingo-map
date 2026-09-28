package com.bingomap.bingo_map.favorite;

import com.bingomap.bingo_map.entity.TargetType;

public record FavoriteRequestDto(
        TargetType targetType,
        String targetId,
        String targetName
) {}
