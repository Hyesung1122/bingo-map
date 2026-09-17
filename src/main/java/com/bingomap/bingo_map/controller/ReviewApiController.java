package com.bingomap.bingo_map.controller;

import com.bingomap.bingo_map.dto.ReviewRequestDto;
import com.bingomap.bingo_map.dto.ReviewResponseDto;
import com.bingomap.bingo_map.dto.RestaurantSummaryDto;
import com.bingomap.bingo_map.service.ReviewService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/reviews")
public class ReviewApiController {

    private final ReviewService reviewService;

    public ReviewApiController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    /** 리뷰 목록. ?restaurantId= 로 특정 맛집 리뷰만 필터링 가능. */
    @GetMapping
    public List<ReviewResponseDto> getReviews(
            @RequestParam(required = false) Long restaurantId) {
        return reviewService.getReviews(restaurantId);
    }

    /** 맛집별로 묶은 리뷰 요약 목록 (리뷰 개수, 평균 별점, 미리보기). 목록(카드형) 화면에서 사용. */
    @GetMapping("/restaurants")
    public List<RestaurantSummaryDto> getRestaurantSummaries() {
        return reviewService.getRestaurantSummaries();
    }

    /** 리뷰 상세. id는 숫자만 허용 (그래야 /restaurants 같은 경로와 안 겹침). */
    @GetMapping("/{id:\\d+}")
    public ReviewResponseDto getReview(@PathVariable Long id) {
        return reviewService.getReview(id);
    }

    /** 리뷰 작성 (사진 최대 5장 첨부, multipart/form-data). */
    @PostMapping(consumes = "multipart/form-data")
    public ResponseEntity<ReviewResponseDto> createReview(
            @RequestPart("review") ReviewRequestDto request,
            @RequestPart(value = "photos", required = false) List<MultipartFile> photos) {
        ReviewResponseDto created = reviewService.create(request, photos);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    /** 리뷰 수정. */
    @PutMapping("/{id:\\d+}")
    public ReviewResponseDto editReview(@PathVariable Long id,
                                         @RequestBody ReviewRequestDto request) {
        return reviewService.edit(id, request);
    }

    /** 리뷰 삭제. */
    @DeleteMapping("/{id:\\d+}")
    public ResponseEntity<Void> deleteReview(@PathVariable Long id) {
        reviewService.delete(id);
        return ResponseEntity.noContent().build();
    }

    /** '도움이 돼요' 클릭. */
    @PostMapping("/{id:\\d+}/helpful")
    public ReviewResponseDto markHelpful(@PathVariable Long id) {
        return reviewService.markHelpful(id);
    }
}
