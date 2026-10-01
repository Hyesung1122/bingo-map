package com.bingomap.bingo_map.user;

/**
 * 마이페이지 프로필 탭 상단 통계 카드(게시글/댓글/리뷰/제보)용 DTO.
 * 전부 내 계정 기준으로 DB에서 센 값이고, 각 카드를 누르면 해당 탭(전체 목록)으로 이동한다.
 */
public class MyPageStatsDto {

    private long postCount;
    private long commentCount;
    private long reviewCount;
    private long reportCount;

    public MyPageStatsDto(long postCount, long commentCount, long reviewCount, long reportCount) {
        this.postCount = postCount;
        this.commentCount = commentCount;
        this.reviewCount = reviewCount;
        this.reportCount = reportCount;
    }

    public long getPostCount() { return postCount; }
    public long getCommentCount() { return commentCount; }
    public long getReviewCount() { return reviewCount; }
    public long getReportCount() { return reportCount; }
}