package com.bingomap.bingo_map.community;

import com.bingomap.bingo_map.user.User;
import com.bingomap.bingo_map.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.Comparator;
import java.util.LinkedHashMap;
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
    private final CommunityPostLikeRepository likeRepository;   // [10/01 유해성] 좋아요

    public CommunityPostService(
            CommunityPostRepository repository,
            CommunityCommentRepository commentRepository,
            UserRepository userRepository,
            CommunityPostLikeRepository likeRepository
    ) {
        this.repository = repository;
        this.commentRepository = commentRepository;
        this.userRepository = userRepository;
        this.likeRepository = likeRepository;
    }

    /**
     * [10/01 유해성] 좋아요 누르기 / 다시 누르면 취소. 로그인 필요, 비공개 요청은 볼 수 있는 사람만.
     * 결과: { liked: 눌린 상태인지, likeCount: 좋아요 수 }
     */
    @Transactional
    public Map<String, Object> toggleLike(Long postId, Long loginUserId, boolean admin) {
        if (loginUserId == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "로그인이 필요합니다.");
        }
        CommunityPost post = findOrThrow(postId);
        if (!canView(post, loginUserId, admin)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "비공개 요청은 작성자와 관리자만 볼 수 있습니다.");
        }

        boolean liked;
        var existing = likeRepository.findByPostIdAndUserId(postId, loginUserId);
        if (existing.isPresent()) {
            likeRepository.delete(existing.get());
            liked = false;
        } else {
            likeRepository.save(new CommunityPostLike(postId, loginUserId));
            liked = true;
        }
        likeRepository.flush();

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("liked", liked);
        result.put("likeCount", likeRepository.countByPostId(postId));
        return result;
    }

    /**
     * 게시글 목록
     * - 최신순
     * - [09/30 유해성] 검색 범위 선택: all(전체) / title(제목) / content(내용) / author(작성자) / comment(댓글)
     *   본문이 CLOB 이라 DB 에서 대소문자 무시 LIKE 가 막혀서, 가져온 뒤 자바에서 걸러냄 (데이터가 적어 부담 없음)
     * - 자바 쪽 페이징
     * - 댓글 개수, 작성자 이름 포함
     * - [10/01 유해성] category(말머리) 필터, 관리자 공지는 맨 위 고정,
     *   비공개 요청은 작성자·관리자가 아니면 내용을 가리고 검색에서도 제외
     */
    public Page<CommunityPostResponseDto> getPosts(
            String keyword,
            String field,
            String category,
            Pageable pageable,
            Long loginUserId,
            boolean admin
    ) {
        Map<Long, String> names = loadDisplayNames();
        Set<Long> adminIds = loadAdminIds();

        List<CommunityPost> all = repository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"));

        // [10/01 유해성] 말머리 탭
        if (category != null && CommunityTags.CATEGORIES.contains(category.trim())) {
            String c = category.trim();
            all = all.stream()
                    .filter(p -> c.equals(CommunityTags.parse(p.getTags())
                            .effectiveCategory(adminIds.contains(p.getUserId()))))
                    .collect(Collectors.toList());
        }

        if (keyword != null && !keyword.isBlank()) {
            // [10/01 유해성] 볼 수 없는 비공개 요청은 검색 대상에서 제외
            all = all.stream()
                    .filter(p -> canView(p, loginUserId, admin))
                    .collect(Collectors.toList());

            String trimmed = keyword.trim();
            String kw = trimmed.toLowerCase(Locale.ROOT);
            String f = field == null ? "all" : field.trim().toLowerCase(Locale.ROOT);

            boolean useTitle = f.equals("all") || f.equals("title");
            boolean useContent = f.equals("all") || f.equals("content");
            boolean useAuthor = f.equals("all") || f.equals("author");
            boolean useComment = f.equals("all") || f.equals("comment");
            boolean useTag = f.equals("all") || f.equals("tag");   // [10/01 유해성] 사이드바 인기 태그 클릭용

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
                            || (useTag && CommunityTags.parse(p.getTags()).userTags.stream()
                                    .anyMatch(t -> t.equalsIgnoreCase(trimmed)))
                            || (useContent && contains(p.getContent(), kw))
                            || (useComment && postIdsByComment.contains(p.getPostId()))
                            || (useAuthor && (userIdsByName.contains(p.getUserId())
                                    || ("회원" + p.getUserId()).equals(trimmed))))
                    .collect(Collectors.toList());
        }

        // [10/01 유해성] 관리자 공지는 모든 페이지 맨 위에 고정.
        // 페이지 나누기는 일반 글로만 하고, 각 페이지 앞에 공지를 붙임.
        // (공지 탭처럼 전부 공지이거나 공지가 없으면 평소처럼 나눔)
        List<CommunityPost> pinned = all.stream()
                .filter(p -> isPinned(p, adminIds))
                .collect(Collectors.toList());
        List<CommunityPost> paged = (pinned.isEmpty() || pinned.size() == all.size())
                ? all
                : all.stream().filter(p -> !isPinned(p, adminIds)).collect(Collectors.toList());
        List<CommunityPost> onTop = paged == all ? List.of() : pinned;

        int start =
                (int) pageable.getOffset();

        int end =
                Math.min(
                        start + pageable.getPageSize(),
                        paged.size()
                );

        List<CommunityPost> pagePosts = new java.util.ArrayList<>(onTop);
        if (start < paged.size()) {
            pagePosts.addAll(paged.subList(start, end));
        }

        List<CommunityPostResponseDto> pageContent =
                pagePosts
                        .stream()
                        .map(p -> toDto(p, names, adminIds, loginUserId, admin))
                        .collect(Collectors.toList());

        // 페이지 수는 일반 글 수 기준 (앞에 붙인 공지 때문에 PageImpl 이 전체 개수를 늘려 잡지 않게 고정)
        long totalPaged = paged.size();
        int totalPages = (int) Math.max(1, (totalPaged + pageable.getPageSize() - 1) / pageable.getPageSize());
        return new PageImpl<>(
                pageContent,
                pageable,
                totalPaged
        ) {
            @Override
            public long getTotalElements() {
                return totalPaged;
            }

            @Override
            public int getTotalPages() {
                return totalPages;
            }
        };
    }

    /**
     * [09/30 유해성] 글쓰기 태그 추천용: 기존 글에서 많이 쓴 태그 30개
     */
    public List<String> getSuggestedTags() {
        // [10/01 유해성] "#" 예약 태그(말머리·상태)는 추천에서 제외
        return repository.findAll().stream()
                .flatMap(p -> CommunityTags.parse(p.getTags()).userTags.stream())
                .collect(Collectors.groupingBy(tag -> tag, Collectors.counting()))
                .entrySet().stream()
                .sorted(Map.Entry.<String, Long>comparingByValue().reversed())
                .limit(30)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
    }

    /**
     * [10/01 유해성] 커뮤니티 오른쪽 사이드바: 인기글 + 내 활동(로그인 시 내 글·댓글 수).
     * 비공개 요청 글은 인기글에서 제외
     */
    public Map<String, Object> getSidebar(Long loginUserId) {
        List<CommunityPost> posts = repository.findAll();
        List<CommunityComment> comments = commentRepository.findAll();

        Map<Long, Long> commentCounts = comments.stream()
                .collect(Collectors.groupingBy(CommunityComment::getPostId, Collectors.counting()));
        Map<Long, Long> likeCounts = likeRepository.findAll().stream()
                .collect(Collectors.groupingBy(CommunityPostLike::getPostId, Collectors.counting()));

        // 인기글: 좋아요를 받은 글만, 좋아요 많은 순 (같으면 조회수 많은 순)
        List<Map<String, Object>> popular = posts.stream()
                .filter(p -> !CommunityTags.parse(p.getTags()).privateRequest)
                .filter(p -> likeCounts.getOrDefault(p.getPostId(), 0L) > 0)
                .sorted(Comparator.comparingLong((CommunityPost p) -> likeCounts.getOrDefault(p.getPostId(), 0L))
                        .thenComparingLong(p -> p.getViewCount() == null ? 0 : p.getViewCount())
                        .reversed())
                .limit(5)
                .map(p -> {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("postId", p.getPostId());
                    m.put("title", p.getTitle());
                    m.put("viewCount", p.getViewCount() == null ? 0 : p.getViewCount());
                    m.put("commentCount", commentCounts.getOrDefault(p.getPostId(), 0L));
                    m.put("likeCount", likeCounts.getOrDefault(p.getPostId(), 0L));
                    return m;
                })
                .collect(Collectors.toList());

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("popular", popular);

        // 내 활동
        if (loginUserId != null) {
            result.put("myPostCount", posts.stream().filter(p -> loginUserId.equals(p.getUserId())).count());
            result.put("myCommentCount", comments.stream().filter(c -> loginUserId.equals(c.getUserId())).count());
        }
        return result;
    }


    /**
     * [09/30 유해성] 작성자 본인 또는 관리자인지 확인. 아니면 401(비로그인) / 403(권한 없음)
     */
    static void checkCanModify(Long ownerId, Long loginUserId, boolean admin, String what) {
        if (loginUserId == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "로그인이 필요합니다.");
        }
        if (!admin && !loginUserId.equals(ownerId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "본인이 작성한 " + what + "만 수정·삭제할 수 있습니다.");
        }
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

    // [10/01 유해성] 관리자(ROLE = 'ADMIN') 회원 번호
    private Set<Long> loadAdminIds() {
        return userRepository.findAll().stream()
                .filter(u -> "ADMIN".equals(u.getRole()))
                .map(User::getUserId)
                .collect(Collectors.toSet());
    }

    // [10/01 유해성] 관리자가 쓴 공지 글이면 목록 맨 위 고정
    private static boolean isPinned(CommunityPost post, Set<Long> adminIds) {
        boolean authorAdmin = adminIds.contains(post.getUserId());
        return authorAdmin && CommunityTags.NOTICE.equals(
                CommunityTags.parse(post.getTags()).effectiveCategory(true));
    }

    // [10/01 유해성] 비공개 요청은 작성자 본인과 관리자만 볼 수 있음
    private static boolean canView(CommunityPost post, Long loginUserId, boolean admin) {
        if (!CommunityTags.parse(post.getTags()).privateRequest) {
            return true;
        }
        return admin || (loginUserId != null && loginUserId.equals(post.getUserId()));
    }

    private CommunityPostResponseDto toDto(CommunityPost post, Map<Long, String> names,
                                           Set<Long> adminIds, Long loginUserId, boolean admin) {
        CommunityPostResponseDto dto = toDtoWithCommentCount(post);
        dto.setAuthorName(names.getOrDefault(post.getUserId(), "회원" + post.getUserId()));
        // [10/01 유해성] 말머리 / 관리자 글 / 공지 고정 / 비공개 가리기
        boolean authorAdmin = adminIds.contains(post.getUserId());
        dto.setAuthorAdmin(authorAdmin);
        dto.setCategory(CommunityTags.parse(post.getTags()).effectiveCategory(authorAdmin));
        dto.setPinned(isPinned(post, adminIds));
        dto.setLiked(loginUserId != null && likeRepository.existsByPostIdAndUserId(post.getPostId(), loginUserId));
        if (!canView(post, loginUserId, admin)) {
            dto.hidePrivateContent();
        }
        return dto;
    }

    /**
     * 게시글 상세
     * 상세 조회 시 조회수 증가
     * 댓글 개수도 함께 반환
     * [10/01 유해성] 비공개 요청은 작성자·관리자가 아니면 내용을 가림
     */
    @Transactional
    public CommunityPostResponseDto getPost(
            Long postId,
            Long loginUserId,
            boolean admin
    ) {
        CommunityPost post =
                findOrThrow(postId);

        post.increaseViewCount();

        return toDto(post, loadDisplayNames(), loadAdminIds(), loginUserId, admin);
    }

    /**
     * [10/01 유해성] 비공개 요청의 댓글은 작성자·관리자만. 볼 수 없으면 401 / 403.
     * 요청 글이면 true (관리자 답변을 위로 올리는 데 사용)
     */
    public boolean checkCanViewComments(Long postId, Long loginUserId, boolean admin) {
        CommunityPost post = findOrThrow(postId);
        if (!canView(post, loginUserId, admin)) {
            if (loginUserId == null) {
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "로그인이 필요합니다.");
            }
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "비공개 요청은 작성자와 관리자만 볼 수 있습니다.");
        }
        return CommunityTags.parse(post.getTags()).isRequest();
    }

    /**
     * [10/01 유해성] 요청 글 처리 상태 변경 (관리자만): 접수 / 처리중 / 완료 / 반려
     */
    @Transactional
    public CommunityPostResponseDto changeStatus(
            Long postId,
            String status,
            Long loginUserId,
            boolean admin
    ) {
        if (loginUserId == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "로그인이 필요합니다.");
        }
        if (!admin) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "관리자만 상태를 바꿀 수 있습니다.");
        }
        if (status == null || !CommunityTags.STATUSES.contains(status.trim())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "상태 값이 올바르지 않습니다.");
        }

        CommunityPost post = findOrThrow(postId);
        CommunityTags tags = CommunityTags.parse(post.getTags());
        if (!tags.isRequest()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "요청 글만 상태를 바꿀 수 있습니다.");
        }
        tags.status = status.trim();
        post.setTags(tags.toRaw());

        return toDto(post, loadDisplayNames(), loadAdminIds(), loginUserId, true);
    }

    /**
     * 게시글 작성
     * [10/01 유해성] 말머리·비공개 여부를 TAGS 예약 태그로 저장, 요청 글은 "접수" 상태로 시작
     */
    @Transactional
    public CommunityPostResponseDto create(
            CommunityPostRequestDto request,
            Long loginUserId,
            boolean admin
    ) {
        CommunityTags tags = new CommunityTags();
        tags.category = CommunityTags.normalizeCategory(request.getCategory(), admin);
        tags.status = CommunityTags.FIRST_STATUS;
        tags.privateRequest = Boolean.TRUE.equals(request.getPrivateRequest());
        tags.userTags = CommunityTags.cleanUserTags(request.getTags());

        // [09/30 유해성] 작성자는 화면이 보낸 값이 아니라 로그인한 사람
        CommunityPost post =
                new CommunityPost(
                        loginUserId,
                        request.getTitle(),
                        request.getContent(),
                        tags.toRaw()
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
            CommunityPostRequestDto request,
            Long loginUserId,
            boolean admin
    ) {
        CommunityPost post =
                findOrThrow(postId);

        // [10/01 유해성] 수정은 작성자 본인만 (관리자도 남의 글은 수정 불가, 삭제는 가능)
        checkCanModify(post.getUserId(), loginUserId, false, "게시글");

        // [10/01 유해성] 말머리는 바꿀 수 있고, 요청 글로 남으면 기존 처리 상태는 유지
        CommunityTags old = CommunityTags.parse(post.getTags());
        CommunityTags tags = new CommunityTags();
        tags.category = request.getCategory() == null
                ? old.category
                : CommunityTags.normalizeCategory(request.getCategory(), admin);
        // 관리자가 쓴 공지를 관리자가 아닌 사람이 고칠 일은 없지만, 기존 공지는 유지
        if (CommunityTags.NOTICE.equals(old.category) && !admin) {
            tags.category = CommunityTags.NOTICE;
        }
        tags.status = old.isRequest() && old.status != null ? old.status : CommunityTags.FIRST_STATUS;
        tags.privateRequest = request.getPrivateRequest() == null
                ? old.privateRequest
                : request.getPrivateRequest();
        tags.userTags = CommunityTags.cleanUserTags(request.getTags());

        post.edit(
                request.getTitle(),
                request.getContent(),
                tags.toRaw()
        );

        return toDtoWithCommentCount(post);
    }

    /**
     * 게시글 삭제
     * 댓글이 먼저 삭제되어야 FK 제약조건에 걸리지 않음
     */
    @Transactional
    public void delete(
            Long postId,
            Long loginUserId,
            boolean admin
    ) {
        CommunityPost post =
                findOrThrow(postId);

        checkCanModify(post.getUserId(), loginUserId, admin, "게시글");

        List<CommunityComment> comments =
                commentRepository
                        .findByPostIdOrderByCreatedAtAsc(postId);

        if (!comments.isEmpty()) {
            commentRepository.deleteAll(comments);
        }

        // [10/01 유해성] 좋아요도 먼저 삭제 (FK_COMMUNITY_POST_LIKE_POST)
        List<CommunityPostLike> likes = likeRepository.findByPostId(postId);
        if (!likes.isEmpty()) {
            likeRepository.deleteAll(likes);
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
        dto.setLikeCount(likeRepository.countByPostId(post.getPostId()));   // [10/01 유해성]

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