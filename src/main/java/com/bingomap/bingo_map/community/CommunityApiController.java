package com.bingomap.bingo_map.community;

import com.bingomap.bingo_map.user.LoginController;
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

@RestController
@RequestMapping("/api/community")
public class CommunityApiController {

    private final CommunityPostService service;
    private final CommunityCommentService commentService;

    public CommunityApiController(
            CommunityPostService service,
            CommunityCommentService commentService
    ) {
        this.service = service;
        this.commentService = commentService;
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
            @RequestParam(defaultValue = "all") String field
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
                pageable
        );
    }

    /**
     * 게시글 상세.
     */
    @GetMapping("/{id:\\d+}")
    public CommunityPostResponseDto getPost(
            @PathVariable Long id
    ) {
        return service.getPost(id);
    }

    /**
     * 게시글 작성.
     */
    @PostMapping
    public ResponseEntity<CommunityPostResponseDto> create(
            @RequestBody CommunityPostRequestDto request
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(service.create(request));
    }

    /**
     * 게시글 수정.
     */
    @PutMapping("/{id:\\d+}")
    public CommunityPostResponseDto edit(
            @PathVariable Long id,
            @RequestBody CommunityPostRequestDto request
    ) {

        return service.edit(
                id,
                request
        );
    }

    /**
     * 게시글 삭제.
     */
    @DeleteMapping("/{id:\\d+}")
    public ResponseEntity<Void> delete(
            @PathVariable Long id
    ) {

        service.delete(id);

        return ResponseEntity.noContent().build();
    }

    /**
     * [09/30 유해성] 글쓰기 화면 태그 추천용 - 많이 쓴 태그 목록.
     */
    @GetMapping("/tags")
    public List<String> getSuggestedTags() {
        return service.getSuggestedTags();
    }

    // ── [09/30 유해성] 댓글 API (병합 중 빠져서 댓글 조회/등록이 실패하던 것 복구) ──

    @GetMapping("/{postId:\\d+}/comments")
    public List<CommentResponseDto> getComments(
            @PathVariable Long postId
    ) {
        return commentService.getComments(postId);
    }

    @PostMapping("/{postId:\\d+}/comments")
    public ResponseEntity<CommentResponseDto> createComment(
            @PathVariable Long postId,
            @RequestBody CommentRequestDto request,
            HttpServletRequest httpRequest
    ) {
        // 로그인했으면 로그인한 사람으로, 아니면 화면이 보낸 id(임시 1번)로 저장
        Long loginUserId = getLoginUserId(httpRequest);
        Long userId = loginUserId != null ? loginUserId : request.getUserId();

        if (userId == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        if (request.getContent() == null || request.getContent().isBlank()) {
            return ResponseEntity.badRequest().build();
        }

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(commentService.create(postId, userId, request.getContent().trim()));
    }

    @DeleteMapping("/comments/{commentId:\\d+}")
    public ResponseEntity<Void> deleteComment(
            @PathVariable Long commentId
    ) {
        commentService.delete(commentId);
        return ResponseEntity.noContent().build();
    }

    private Long getLoginUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute(LoginController.SESSION_USER_ID);
        if (value instanceof Number) {
            return ((Number) value).longValue();
        }
        return null;
    }
}
