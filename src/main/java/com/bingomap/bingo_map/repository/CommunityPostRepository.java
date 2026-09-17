package com.bingomap.bingo_map.repository;

import com.bingomap.bingo_map.entity.CommunityPost;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CommunityPostRepository extends JpaRepository<CommunityPost, Long> {

    // 오라클 버전이 OFFSET/FETCH 페이징 문법(ORA-00933)을 지원하지 않아
    // Pageable 대신 Sort로 전체를 가져온 뒤 서비스 계층에서 직접 자른다.
    List<CommunityPost> findAll(Sort sort);

    List<CommunityPost> findByTitleContainingIgnoreCaseOrContentContainingIgnoreCase(
            String titleKeyword, String contentKeyword, Sort sort);
}
