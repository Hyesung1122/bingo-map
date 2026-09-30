package com.bingomap.bingo_map.community;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface CommunityCommentRepository extends JpaRepository<CommunityComment, Long> {
    List<CommunityComment> findByPostIdOrderByCreatedAtAsc(Long postId);
    long countByPostId(Long postId);

    // [09/30 유해성] 댓글 내용 검색 (댓글 CONTENT 는 VARCHAR2 라 대소문자 무시 비교 가능)
    List<CommunityComment> findByContentContainingIgnoreCase(String keyword);
}
