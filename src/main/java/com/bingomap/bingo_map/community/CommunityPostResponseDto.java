package com.bingomap.bingo_map.community;

import java.time.LocalDateTime;
import java.util.List;

public class CommunityPostResponseDto {

    private Long postId;
    private Long userId;
    private String title;
    private String content;
    private List<String> tags;
    private Integer viewCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private long commentCount;
    private String authorName;   // [09/30 유해성] 작성자 닉네임(없으면 이름)

    // [10/01 유해성] TAGS 의 예약 태그를 나눠서 전달 (tags 에는 일반 태그만)
    private String category;          // 자유 / 질문 / 꿀팁 / 요청 / 공지
    private String status;            // 요청 글 상태: 접수 / 처리중 / 완료 / 반려
    private boolean privateRequest;   // 비공개 요청
    private boolean hidden;           // 비공개라 내용을 가렸는지
    private boolean authorAdmin;      // 관리자가 쓴 글
    private boolean pinned;           // 목록 맨 위 고정(관리자 공지)
    private long likeCount;           // 좋아요 수
    private boolean liked;            // 보고 있는 사람이 좋아요를 눌렀는지

    public CommunityPostResponseDto(CommunityPost post) {
        this.postId = post.getPostId();
        this.userId = post.getUserId();
        this.title = post.getTitle();
        this.content = post.getContent();

        CommunityTags parsed = CommunityTags.parse(post.getTags());
        this.tags = parsed.userTags;
        this.category = parsed.category;
        this.status = parsed.status;
        this.privateRequest = parsed.privateRequest;

        this.viewCount = post.getViewCount();
        this.createdAt = post.getCreatedAt();
        this.updatedAt = post.getUpdatedAt();
    }

    /** [10/01 유해성] 작성자·관리자가 아닌 사람에게 비공개 요청 내용을 가림 */
    public void hidePrivateContent() {
        this.title = "🔒 비공개 요청입니다";
        this.content = "";
        this.tags = List.of();
        this.hidden = true;
    }

    public Long getPostId() {
        return postId;
    }

    public Long getUserId() {
        return userId;
    }

    public String getTitle() {
        return title;
    }

    public String getContent() {
        return content;
    }

    public List<String> getTags() {
        return tags;
    }

    public Integer getViewCount() {
        return viewCount;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public long getCommentCount() {
        return commentCount;
    }

    public void setCommentCount(long commentCount) {
        this.commentCount = commentCount;
    }

    public String getAuthorName() {
        return authorName;
    }

    public void setAuthorName(String authorName) {
        this.authorName = authorName;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getStatus() {
        return status;
    }

    public boolean isPrivateRequest() {
        return privateRequest;
    }

    public boolean isHidden() {
        return hidden;
    }

    public boolean isAuthorAdmin() {
        return authorAdmin;
    }

    public void setAuthorAdmin(boolean authorAdmin) {
        this.authorAdmin = authorAdmin;
    }

    public boolean isPinned() {
        return pinned;
    }

    public void setPinned(boolean pinned) {
        this.pinned = pinned;
    }

    public long getLikeCount() {
        return likeCount;
    }

    public void setLikeCount(long likeCount) {
        this.likeCount = likeCount;
    }

    public boolean isLiked() {
        return liked;
    }

    public void setLiked(boolean liked) {
        this.liked = liked;
    }
}
