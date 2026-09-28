package com.bingomap.bingo_map.user;

/**
 * 마이페이지 프로필 탭 상단 통계 카드용 DTO.
 * favoriteCount / reportCount는 아직 관련 기능이 없어서 0으로 고정.
 */
public class MyPageStatsDto {

    private long reviewCount;
    private long reportCount;
    private long favoriteCount;
    private long helpCountTotal; // 내가 쓴 리뷰들이 받은 '도움이 돼요' 합계

    public MyPageStatsDto(long reviewCount, long reportCount, long favoriteCount, long helpCountTotal) {
        this.reviewCount = reviewCount;
        this.reportCount = reportCount;
        this.favoriteCount = favoriteCount;
        this.helpCountTotal = helpCountTotal;
    }

    public long getReviewCount() { return reviewCount; }
    public long getReportCount() { return reportCount; }
    public long getFavoriteCount() { return favoriteCount; }
    public long getHelpCountTotal() { return helpCountTotal; }
}