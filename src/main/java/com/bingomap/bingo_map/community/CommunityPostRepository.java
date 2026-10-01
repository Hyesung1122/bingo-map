package com.bingomap.bingo_map.community;

import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CommunityPostRepository extends JpaRepository<CommunityPost, Long> {

    List<CommunityPost> findAll(Sort sort);

    // [09/30 유해성] findByTitleContainingIgnoreCaseOrContentContainingIgnoreCase 삭제
    // 본문(CONTENT)이 CLOB 이라 대소문자 무시 비교가 오라클/Hibernate 에서 막힘.
    // 검색은 CommunityPostService.getPosts() 에서 자바로 처리함.

    // 마이페이지 "작성한 게시글" 탭/통계용
    List<CommunityPost> findByUserIdOrderByCreatedAtDesc(Long userId);
    long countByUserId(Long userId);
}