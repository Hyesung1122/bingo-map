package com.bingomap.bingo_map.favorite;

/** 식당 카드의 하트 상태를 표시하기 위한 최소 응답. */
public record FavoriteStatusDto(String targetId, Long favoriteId) {
}
