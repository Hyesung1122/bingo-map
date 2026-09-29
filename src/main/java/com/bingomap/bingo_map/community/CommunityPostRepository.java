package com.bingomap.bingo_map.community;

import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CommunityPostRepository extends JpaRepository<CommunityPost, Long> {

    List<CommunityPost> findAll(Sort sort);

    List<CommunityPost> findByTitleContainingIgnoreCaseOrContentContainingIgnoreCase(
            String titleKeyword,
            String contentKeyword,
            Sort sort
    );
}