package com.bingomap.bingo_map.community;

import com.bingomap.bingo_map.user.User;
import com.bingomap.bingo_map.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class CommunityPostService {

    private final CommunityPostRepository repository;
    private final CommunityCommentRepository commentRepository;
    private final UserRepository userRepository;

    public CommunityPostService(
            CommunityPostRepository repository,
            CommunityCommentRepository commentRepository,
            UserRepository userRepository
    ) {
        this.repository = repository;
        this.commentRepository = commentRepository;
        this.userRepository = userRepository;
    }

    /**
     * 게시글 목록
     * - 최신순
     * - [09/30 유해성] 검색 범위 선택: all(전체) / title(제목) / content(내용) / author(작성자) / comment(댓글)
     *   본문이 CLOB 이라 DB 에서 대소문자 무시 LIKE 가 막혀서, 가져온 뒤 자바에서 걸러냄 (데이터가 적어 부담 없음)
     * - 자바 쪽 페이징
     * - 댓글 개수, 작성자 이름 포함
     */
    public Page<CommunityPostResponseDto> getPosts(
            String keyword,
            String field,
            Pageable pageable
    ) {
        Map<Long, String> names = loadDisplayNames();

        List<CommunityPost> all = repository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"));

        if (keyword != null && !keyword.isBlank()) {
            String trimmed = keyword.trim();
            String kw = trimmed.toLowerCase(Locale.ROOT);
            String f = field == null ? "all" : field.trim().toLowerCase(Locale.ROOT);

            boolean useTitle = f.equals("all") || f.equals("title");
            boolean useContent = f.equals("all") || f.equals("content");
            boolean useAuthor = f.equals("all") || f.equals("author");
            boolean useComment = f.equals("all") || f.equals("comment");

            Set<Long> postIdsByComment = useComment
                    ? commentRepository.findByContentContainingIgnoreCase(trimmed).stream()
                        .map(CommunityComment::getPostId)
                        .collect(Collectors.toSet())
                    : Set.of();

            Set<Long> userIdsByName = useAuthor
                    ? names.entrySet().stream()
                        .filter(e -> contains(e.getValue(), kw) || ("회원" + e.getKey()).equals(trimmed))
                        .map(Map.Entry::getKey)
                        .collect(Collectors.toSet())
                    : Set.of();

            all = all.stream()
                    .filter(p -> (useTitle && contains(p.getTitle(), kw))
                            || (useContent && contains(p.getContent(), kw))
                            || (useComment && postIdsByComment.contains(p.getPostId()))
                            || (useAuthor && (userIdsByName.contains(p.getUserId())
                                    || ("회원" + p.getUserId()).equals(trimmed))))
                    .collect(Collectors.toList());
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
                        .map(p -> toDto(p, names))
                        .collect(Collectors.toList());

        return new PageImpl<>(
                pageContent,
                pageable,
                all.size()
        );
    }

    /**
     * [09/30 유해성] 글쓰기 태그 추천용: 기존 글에서 많이 쓴 태그 30개
     */
    public List<String> getSuggestedTags() {
        return repository.findAll().stream()
                .map(CommunityPost::getTags)
                .filter(tags -> tags != null && !tags.isBlank())
                .flatMap(tags -> Arrays.stream(tags.split(",")))
                .map(String::trim)
                .filter(tag -> !tag.isEmpty())
                .collect(Collectors.groupingBy(tag -> tag, Collectors.counting()))
                .entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
                .limit(30)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
    }

    private static boolean contains(String text, String lowerKeyword) {
        return text != null && text.toLowerCase(Locale.ROOT).contains(lowerKeyword);
    }

    // [09/30 유해성] 닉네임 -> 이름 -> "회원N" 순서로 작성자 표시 이름
    static String displayName(User u) {
        if (u.getNickname() != null && !u.getNickname().isBlank()) {
            return u.getNickname();
        }
        if (u.getName() != null && !u.getName().isBlank()) {
            return u.getName();
        }
        return "회원" + u.getUserId();
    }

    private Map<Long, String> loadDisplayNames() {
        return userRepository.findAll().stream()
                .collect(Collectors.toMap(User::getUserId, CommunityPostService::displayName, (a, b) -> a));
    }

    private CommunityPostResponseDto toDto(CommunityPost post, Map<Long, String> names) {
        CommunityPostResponseDto dto = toDtoWithCommentCount(post);
        dto.setAuthorName(names.getOrDefault(post.getUserId(), "회원" + post.getUserId()));
        return dto;
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

        return toDto(post, loadDisplayNames());
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