package com.bingomap.bingo_map.review;

import com.bingomap.bingo_map.restaurant.RestaurantSummaryDto;
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

    @GetMapping
    public List<ReviewResponseDto> getReviews(
            @RequestParam(required = false) Long restaurantId) {

        return reviewService.getReviews(restaurantId);
    }

    @GetMapping("/restaurants")
    public List<RestaurantSummaryDto> getRestaurantSummaries() {
        return reviewService.getRestaurantSummaries();
    }

    @GetMapping("/{id:\\d+}")
    public ReviewResponseDto getReview(
            @PathVariable Long id) {

        return reviewService.getReview(id);
    }

    @PostMapping(consumes = "multipart/form-data")
    public ResponseEntity<ReviewResponseDto> createReview(
            @RequestPart("review") ReviewRequestDto request,
            @RequestPart(value = "photos", required = false)
            List<MultipartFile> photos) {

        ReviewResponseDto created =
                reviewService.create(request, photos);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(created);
    }

    @PutMapping("/{id:\\d+}")
    public ReviewResponseDto editReview(
            @PathVariable Long id,
            @RequestBody ReviewRequestDto request) {

        return reviewService.edit(id, request);
    }

    @DeleteMapping("/{id:\\d+}")
    public ResponseEntity<Void> deleteReview(
            @PathVariable Long id) {

        reviewService.delete(id);

        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id:\\d+}/helpful")
    public ReviewResponseDto markHelpful(
            @PathVariable Long id) {

        return reviewService.markHelpful(id);
    }
}