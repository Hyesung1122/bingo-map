package com.bingomap.bingo_map.community;

import com.bingomap.bingo_map.user.LoginController;
import com.bingomap.bingo_map.user.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/community")
public class CommunityApiController {

    private final CommunityPostService service;
    private final CommunityCommentService commentService;
    private final UserRepository userRepository;

    public CommunityApiController(
            CommunityPostService service,
            CommunityCommentService commentService,
            UserRepository userRepository
    ) {
        this.service = service;
        this.commentService = commentService;
        this.userRepository = userRepository;
    }

    /**
     * 게시글 목록.
     * page / size / keyword / field 로 페이징 및 검색.
     * [09/30 유해성] field = all(전체) / title(제목) / content(내용) / author(작성자) / comment(댓글)
     */
    @GetMapping
    public Page<CommunityPostResponseDto> getPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "all") String field,
            @RequestParam(required = false) String category,   // [10/01 유해성] 말머리 탭
            HttpServletRequest httpRequest
    ) {

        Pageable pageable =
                PageRequest.of(
                        page,
                        size,
                        Sort.by(
                                Sort.Direction.DESC,
                                "createdAt"
                        )
                );

        return service.getPosts(
                keyword,
                field,
                category,
                pageable,
                getLoginUserId(httpRequest),
                canModerate(httpRequest)
        );
    }

    /**
     * 게시글 상세.
     * [10/01 유해성] 비공개 요청은 작성자·관리자가 아니면 내용이 가려져서 내려감
     */
    @GetMapping("/{id:\\d+}")
    public CommunityPostResponseDto getPost(
            @PathVariable Long id,
            HttpServletRequest httpRequest
    ) {
        return service.getPost(id, getLoginUserId(httpRequest), canModerate(httpRequest));
    }

    /**
     * [10/01 유해성] 요청 글 처리 상태 변경 (관리자만). body: { "status": "처리중" }
     */
    @PatchMapping("/{id:\\d+}/status")
    public CommunityPostResponseDto changeStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> body,
            HttpServletRequest httpRequest
    ) {
        return service.changeStatus(
                id,
                body.get("status"),
                getLoginUserId(httpRequest),
                canModerate(httpRequest)
        );
    }

    /**
     * 게시글 작성.
     */
    @PostMapping
    public ResponseEntity<CommunityPostResponseDto> create(
            @RequestBody CommunityPostRequestDto request,
            HttpServletRequest httpRequest
    ) {
        // [09/30 유해성] 로그인한 사람만 작성, 작성자는 로그인 정보로 저장
        Long loginUserId = getLoginUserId(httpRequest);
        if (loginUserId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(service.create(request, loginUserId, isAdmin(httpRequest)));
    }

    /**
     * 게시글 수정.
     */
    @PutMapping("/{id:\\d+}")
    public CommunityPostResponseDto edit(
            @PathVariable Long id,
            @RequestBody CommunityPostRequestDto request,
            HttpServletRequest httpRequest
    ) {
        // [09/30 유해성] 작성자 본인 또는 관리자만
        return service.edit(
                id,
                request,
                getLoginUserId(httpRequest),
                isAdmin(httpRequest)
        );
    }

    /**
     * 게시글 삭제.
     */
    @DeleteMapping("/{id:\\d+}")
    public ResponseEntity<Void> delete(
            @PathVariable Long id,
            HttpServletRequest httpRequest
    ) {
        // [09/30 유해성] 작성자 본인 또는 관리자만
        service.delete(id, getLoginUserId(httpRequest), canModerate(httpRequest));

        return ResponseEntity.noContent().build();
    }

    /**
     * [09/30 유해성] 글쓰기 화면 태그 추천용 - 많이 쓴 태그 목록.
     */
    @GetMapping("/tags")
    public List<String> getSuggestedTags() {
        return service.getSuggestedTags();
    }

    /**
     * [10/01 유해성] 좋아요 누르기 / 다시 누르면 취소 (로그인 필요)
     */
    @PostMapping("/{id:\\d+}/like")
    public Map<String, Object> toggleLike(
            @PathVariable Long id,
            HttpServletRequest httpRequest
    ) {
        return service.toggleLike(id, getLoginUserId(httpRequest), isAdmin(httpRequest));
    }

    /**
     * [10/01 유해성] 커뮤니티 오른쪽 사이드바 (인기글 / 내 활동)
     */
    @GetMapping("/sidebar")
    public Map<String, Object> getSidebar(HttpServletRequest httpRequest) {
        return service.getSidebar(getLoginUserId(httpRequest));
    }

    // ── [09/30 유해성] 댓글 API (병합 중 빠져서 댓글 조회/등록이 실패하던 것 복구) ──

    @GetMapping("/{postId:\\d+}/comments")
    public List<CommentResponseDto> getComments(
            @PathVariable Long postId,
            HttpServletRequest httpRequest
    ) {
        // [10/01 유해성] 비공개 요청 댓글은 작성자·관리자만, 요청 글은 관리자 답변을 위로
        boolean requestPost = service.checkCanViewComments(
                postId, getLoginUserId(httpRequest), canModerate(httpRequest));
        return commentService.getComments(postId, requestPost);
    }

    @PostMapping("/{postId:\\d+}/comments")
    public ResponseEntity<CommentResponseDto> createComment(
            @PathVariable Long postId,
            @RequestBody CommentRequestDto request,
            HttpServletRequest httpRequest
    ) {
        // [09/30 유해성] 로그인한 사람만 댓글 작성, 작성자는 로그인 정보로 저장
        Long userId = getLoginUserId(httpRequest);

        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        if (request.getContent() == null || request.getContent().isBlank()) {
            return ResponseEntity.badRequest().build();
        }
        // [10/01 유해성] 비공개 요청에는 작성자·관리자만 댓글 가능 (아니면 403)
        service.checkCanViewComments(postId, userId, canModerate(httpRequest));

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(commentService.create(postId, userId, request.getContent().trim()));
    }

    @DeleteMapping("/comments/{commentId:\\d+}")
    public ResponseEntity<Void> deleteComment(
            @PathVariable Long commentId,
            HttpServletRequest httpRequest
    ) {
        // [09/30 유해성] 댓글 작성자 본인 또는 관리자만
        commentService.delete(commentId, getLoginUserId(httpRequest), canModerate(httpRequest));
        return ResponseEntity.noContent().build();
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null
                && "ADMIN".equals(session.getAttribute(LoginController.SESSION_USER_ROLE));
    }

    private boolean canModerate(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        Object role = session.getAttribute(LoginController.SESSION_USER_ROLE);
        return "ADMIN".equals(role) || "MANAGER".equals(role);
    }

    /**
     * [10/01 유해성] 로그인한 회원 번호. 세션에 번호가 있어도 USERS 에 없는 회원이면
     * (DB 를 다시 만든 뒤 예전 로그인이 남아 있는 경우) 세션을 지우고 비로그인으로 처리.
     * -> 댓글/글 저장 시 ORA-02291(FK_..._USER, 부모 키 없음) 대신 로그인 페이지로 안내됨
     */
    private Long getLoginUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute(LoginController.SESSION_USER_ID);
        if (!(value instanceof Number)) {
            return null;
        }
        Long userId = ((Number) value).longValue();
        if (!userRepository.existsById(userId)) {
            session.invalidate();
            return null;
        }
        return userId;
    }
}
