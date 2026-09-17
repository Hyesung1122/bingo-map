package com.bingomap.bingo_map.service;

import com.bingomap.bingo_map.dto.CommunityPostRequestDto;
import com.bingomap.bingo_map.dto.CommunityPostResponseDto;
import com.bingomap.bingo_map.entity.CommunityPost;
import com.bingomap.bingo_map.repository.CommunityPostRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class CommunityPostService {

    private final CommunityPostRepository repository;

    public CommunityPostService(CommunityPostRepository repository) {
        this.repository = repository;
    }

    /**
     * 게시글 목록 (검색 + 페이징, 최신순).
     * 오라클이 OFFSET/FETCH 페이징 문법을 지원하지 않아, Pageable을 쿼리에 그대로
     * 넘기지 않고 전체(정렬만 적용)를 가져온 뒤 자바에서 페이지만큼 잘라낸다.
     */
    public Page<CommunityPostResponseDto> getPosts(String keyword, Pageable pageable) {
        Sort sort = Sort.by(Sort.Direction.DESC, "createdAt");

        List<CommunityPost> all = (keyword == null || keyword.isBlank())
                ? repository.findAll(sort)
                : repository.findByTitleContainingIgnoreCaseOrContentContainingIgnoreCase(keyword, keyword, sort);

        int start = (int) pageable.getOffset();
        if (start >= all.size()) {
            return new PageImpl<>(List.of(), pageable, all.size());
        }
        int end = Math.min(start + pageable.getPageSize(), all.size());

        List<CommunityPostResponseDto> pageContent = all.subList(start, end).stream()
                .map(CommunityPostResponseDto::new)
                .collect(Collectors.toList());

        return new PageImpl<>(pageContent, pageable, all.size());
    }

    /** 게시글 상세 (조회할 때마다 조회수 1 증가). */
    @Transactional
    public CommunityPostResponseDto getPost(Long postId) {
        CommunityPost post = findOrThrow(postId);
        post.increaseViewCount();
        return new CommunityPostResponseDto(post);
    }

    @Transactional
    public CommunityPostResponseDto create(CommunityPostRequestDto request) {
        CommunityPost post = new CommunityPost(
                request.getUserId(), request.getTitle(), request.getContent(), request.getTags());
        return new CommunityPostResponseDto(repository.save(post));
    }

    @Transactional
    public CommunityPostResponseDto edit(Long postId, CommunityPostRequestDto request) {
        CommunityPost post = findOrThrow(postId);
        post.edit(request.getTitle(), request.getContent(), request.getTags());
        return new CommunityPostResponseDto(post);
    }

    @Transactional
    public void delete(Long postId) {
        repository.delete(findOrThrow(postId));
    }

    private CommunityPost findOrThrow(Long postId) {
        return repository.findById(postId)
                .orElseThrow(() -> new EntityNotFoundException("게시글을 찾을 수 없습니다. id=" + postId));
    }
}
