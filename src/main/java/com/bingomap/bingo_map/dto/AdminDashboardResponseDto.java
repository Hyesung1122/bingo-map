package com.bingomap.bingo_map.dto;

import lombok.Getter;

/**
 * GET /api/admin/dashboard 응답용 DTO.
 * memberCount는 실제 TB_USER 기준 값이고, 나머지(binCount, restaurantCount, pendingReportCount)는
 * 쓰레기통/맛집/제보 기능이 아직 없어서 0으로 고정된 자리만 잡아둔 값이다.
 * 해당 기능이 만들어지면 그 담당 Repository로 교체하면 된다.
 */
@Getter
public class AdminDashboardResponseDto {
    private final long memberCount;
    private final long binCount;
    private final long restaurantCount;
    private final long pendingReportCount;

    public AdminDashboardResponseDto(long memberCount, long binCount, long restaurantCount, long pendingReportCount) {
        this.memberCount = memberCount;
        this.binCount = binCount;
        this.restaurantCount = restaurantCount;
        this.pendingReportCount = pendingReportCount;
    }
}