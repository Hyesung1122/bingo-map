package com.bingomap.bingo_map.community;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/community")
public class CommunityApiController {

    private final CommunityPostService service;

    public CommunityApiController(
            CommunityPostService service
    ) {
        this.service = service;
    }

    /**
     * 게시글 목록.
     * page / size / keyword로 페이징 및 검색.
     */
    @GetMapping
    public Page<CommunityPostResponseDto> getPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String keyword
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
}