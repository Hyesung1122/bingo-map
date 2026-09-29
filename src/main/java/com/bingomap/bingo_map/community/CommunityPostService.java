package com.bingomap.bingo_map.community;

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
    private final CommunityCommentRepository commentRepository;

    public CommunityPostService(
            CommunityPostRepository repository,
            CommunityCommentRepository commentRepository
    ) {
        this.repository = repository;
        this.commentRepository = commentRepository;
    }

    /**
     * 게시글 목록
     * - 최신순
     * - 제목/내용 검색
     * - Pageable을 이용한 자바 쪽 페이징
     * - 댓글 개수 포함
     */
    public Page<CommunityPostResponseDto> getPosts(
            String keyword,
            Pageable pageable
    ) {
        Sort sort =
                Sort.by(
                        Sort.Direction.DESC,
                        "createdAt"
                );

        List<CommunityPost> all;

        if (keyword == null || keyword.isBlank()) {
            all = repository.findAll(sort);
        } else {
            all = repository
                    .findByTitleContainingIgnoreCaseOrContentContainingIgnoreCase(
                            keyword,
                            keyword,
                            sort
                    );
        }

        int start =
                (int) pageable.getOffset();

        if (start >= all.size()) {
            return new PageImpl<>(
                    List.of(),
                    pageable,
                    all.size()
            );
        }

        int end =
                Math.min(
                        start + pageable.getPageSize(),
                        all.size()
                );

        List<CommunityPostResponseDto> pageContent =
                all.subList(start, end)
                        .stream()
                        .map(this::toDtoWithCommentCount)
                        .collect(Collectors.toList());

        return new PageImpl<>(
                pageContent,
                pageable,
                all.size()
        );
    }

    /**
     * 게시글 상세
     * 상세 조회 시 조회수 증가
     * 댓글 개수도 함께 반환
     */
    @Transactional
    public CommunityPostResponseDto getPost(
            Long postId
    ) {
        CommunityPost post =
                findOrThrow(postId);

        post.increaseViewCount();

        return toDtoWithCommentCount(post);
    }

    /**
     * 게시글 작성
     */
    @Transactional
    public CommunityPostResponseDto create(
            CommunityPostRequestDto request
    ) {
        CommunityPost post =
                new CommunityPost(
                        request.getUserId(),
                        request.getTitle(),
                        request.getContent(),
                        request.getTags()
                );

        CommunityPost saved =
                repository.save(post);

        return toDtoWithCommentCount(saved);
    }

    /**
     * 게시글 수정
     */
    @Transactional
    public CommunityPostResponseDto edit(
            Long postId,
            CommunityPostRequestDto request
    ) {
        CommunityPost post =
                findOrThrow(postId);

        post.edit(
                request.getTitle(),
                request.getContent(),
                request.getTags()
        );

        return toDtoWithCommentCount(post);
    }

    /**
     * 게시글 삭제
     * 댓글이 먼저 삭제되어야 FK 제약조건에 걸리지 않음
     */
    @Transactional
    public void delete(
            Long postId
    ) {
        CommunityPost post =
                findOrThrow(postId);

        List<CommunityComment> comments =
                commentRepository
                        .findByPostIdOrderByCreatedAtAsc(postId);

        if (!comments.isEmpty()) {
            commentRepository.deleteAll(comments);
        }

        repository.delete(post);
    }

    private CommunityPostResponseDto toDtoWithCommentCount(
            CommunityPost post
    ) {
        CommunityPostResponseDto dto =
                new CommunityPostResponseDto(post);

        long commentCount =
                commentRepository.countByPostId(
                        post.getPostId()
                );

        dto.setCommentCount(commentCount);

        return dto;
    }

    private CommunityPost findOrThrow(
            Long postId
    ) {
        return repository
                .findById(postId)
                .orElseThrow(
                        () -> new EntityNotFoundException(
                                "게시글을 찾을 수 없습니다. id="
                                        + postId
                        )
                );
    }
}