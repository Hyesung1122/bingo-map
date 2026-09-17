package com.bingomap.bingo_map.controller;

import com.bingomap.bingo_map.dto.CommunityPostRequestDto;
import com.bingomap.bingo_map.dto.CommunityPostResponseDto;
import com.bingomap.bingo_map.service.CommunityPostService;
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

    public CommunityApiController(CommunityPostService service) {
        this.service = service;
    }

    /** 게시글 목록. page/size/keyword 로 페이징 및 검색. 최신순 정렬. */
    @GetMapping
    public Page<CommunityPostResponseDto> getPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String keyword) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        return service.getPosts(keyword, pageable);
    }

    @GetMapping("/{id}")
    public CommunityPostResponseDto getPost(@PathVariable Long id) {
        return service.getPost(id);
    }

    @PostMapping
    public ResponseEntity<CommunityPostResponseDto> create(@RequestBody CommunityPostRequestDto request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.create(request));
    }

    @PutMapping("/{id}")
    public CommunityPostResponseDto edit(@PathVariable Long id, @RequestBody CommunityPostRequestDto request) {
        return service.edit(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }
}
