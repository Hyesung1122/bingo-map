package com.bingomap.bingo_map.service;

import com.bingomap.bingo_map.dto.ReviewRequestDto;
import com.bingomap.bingo_map.dto.ReviewResponseDto;
import com.bingomap.bingo_map.dto.RestaurantSummaryDto;
import com.bingomap.bingo_map.entity.Review;
import com.bingomap.bingo_map.entity.ReviewImage;
import com.bingomap.bingo_map.repository.ReviewRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class ReviewService {

    // 리뷰 이미지 1건당 최대 첨부 개수 (TB_REVIEW_IMAGE 정책: 최대 5장)
    private static final int MAX_IMAGE_COUNT = 5;

    // 업로드된 이미지 파일이 저장되는 실제 경로 (프로젝트 루트 기준)
    private static final Path UPLOAD_DIR = Paths.get("uploads", "reviews");

    private final ReviewRepository reviewRepository;

    public ReviewService(ReviewRepository reviewRepository) {
        this.reviewRepository = reviewRepository;
    }

    /** 리뷰 목록 조회. restaurantId가 주어지면 해당 맛집 리뷰만 조회한다. */
    public List<ReviewResponseDto> getReviews(Long restaurantId) {
        List<Review> reviews = (restaurantId == null)
                ? reviewRepository.findAllByOrderByCreatedAtDesc()
                : reviewRepository.findByRestaurantIdOrderByCreatedAtDesc(restaurantId);

        return reviews.stream()
                .map(ReviewResponseDto::new)
                .collect(Collectors.toList());
    }

    /**
     * 게시판 목록 조회 (검색 + 페이징 + 정렬).
     * 오라클이 OFFSET/FETCH 페이징 문법을 지원하지 않아 Pageable을 쿼리에 바로 넘기지 않고
     * 정렬만 적용해 전체를 가져온 뒤 자바에서 페이지만큼 잘라낸다.
     */
    public Page<ReviewResponseDto> getReviewsPage(String keyword, Pageable pageable) {
        List<Review> all = (keyword == null || keyword.isBlank())
                ? reviewRepository.findAllByOrderByCreatedAtDesc()
                : reviewRepository.findByContentContainingIgnoreCase(keyword, pageable.getSort());

        int start = (int) pageable.getOffset();
        if (start >= all.size()) {
            return new org.springframework.data.domain.PageImpl<>(List.of(), pageable, all.size());
        }
        int end = Math.min(start + pageable.getPageSize(), all.size());

        List<ReviewResponseDto> pageContent = all.subList(start, end).stream()
                .map(ReviewResponseDto::new)
                .collect(Collectors.toList());

        return new org.springframework.data.domain.PageImpl<>(pageContent, pageable, all.size());
    }

    /** 맛집별로 묶은 리뷰 요약 목록 (카드형 화면용). */
    public List<RestaurantSummaryDto> getRestaurantSummaries() {
        return reviewRepository.findRestaurantSummaries().stream()
                .map(summary -> {
                    List<Review> latest = reviewRepository
                            .findByRestaurantIdOrderByCreatedAtDesc(summary.getRestaurantId());
                    String preview = latest.isEmpty() ? "" : latest.get(0).getContent();
                    String thumbnail = latest.stream()
                            .flatMap(r -> r.getImages().stream())
                            .map(ReviewImage::getImageUrl)
                            .findFirst()
                            .orElse(null);
                    return new RestaurantSummaryDto(
                            summary.getRestaurantId(),
                            summary.getReviewCount(),
                            summary.getAvgRating(),
                            preview,
                            thumbnail
                    );
                })
                .collect(Collectors.toList());
    }

    /** 리뷰 상세 조회. */
    public ReviewResponseDto getReview(Long reviewId) {
        return new ReviewResponseDto(findReviewOrThrow(reviewId));
    }

    /** 리뷰 작성 (사진 최대 5장 포함). */
    @Transactional
    public ReviewResponseDto create(ReviewRequestDto request, List<MultipartFile> photos) {
        Review review = new Review(
                request.getUserId(),
                request.getRestaurantId(),
                request.getRating(),
                request.getContent(),
                request.getVisitDate(),
                request.getVisitTimeSlot(),
                request.getVisitPurpose(),
                request.getRecommendYn()
        );

        attachImages(review, photos);

        Review saved = reviewRepository.save(review);
        return new ReviewResponseDto(saved);
    }

    /** 리뷰 수정. */
    @Transactional
    public ReviewResponseDto edit(Long reviewId, ReviewRequestDto request) {
        Review review = findReviewOrThrow(reviewId);
        review.edit(
                request.getRating(),
                request.getContent(),
                request.getVisitDate(),
                request.getVisitTimeSlot(),
                request.getVisitPurpose(),
                request.getRecommendYn()
        );
        return new ReviewResponseDto(review);
    }

    /** 리뷰 삭제. */
    @Transactional
    public void delete(Long reviewId) {
        Review review = findReviewOrThrow(reviewId);
        reviewRepository.delete(review);
    }

    /** '도움이 돼요' 카운트 증가. */
    @Transactional
    public ReviewResponseDto markHelpful(Long reviewId) {
        Review review = findReviewOrThrow(reviewId);
        review.markHelpful();
        return new ReviewResponseDto(review);
    }

    private Review findReviewOrThrow(Long reviewId) {
        return reviewRepository.findById(reviewId)
                .orElseThrow(() -> new EntityNotFoundException("리뷰를 찾을 수 없습니다. id=" + reviewId));
    }

    private void attachImages(Review review, List<MultipartFile> photos) {
        if (photos == null || photos.isEmpty()) {
            return;
        }

        int limit = Math.min(photos.size(), MAX_IMAGE_COUNT);
        for (int i = 0; i < limit; i++) {
            MultipartFile photo = photos.get(i);
            if (photo == null || photo.isEmpty()) {
                continue;
            }
            String url = storeFile(photo);
            review.addImage(ReviewImage.upload(url, i));
        }
    }

    /** 업로드된 파일을 uploads/reviews/ 아래에 저장하고, 정적으로 서빙되는 URL을 반환한다. */
    private String storeFile(MultipartFile photo) {
        try {
            Files.createDirectories(UPLOAD_DIR);

            String original = photo.getOriginalFilename() == null ? "" : photo.getOriginalFilename();
            String ext = original.contains(".") ? original.substring(original.lastIndexOf('.')) : "";
            String fileName = UUID.randomUUID() + ext;

            Path target = UPLOAD_DIR.resolve(fileName);
            try (InputStream in = photo.getInputStream()) {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
            }

            return "/uploads/reviews/" + fileName;
        } catch (IOException e) {
            throw new IllegalStateException("리뷰 이미지 저장에 실패했습니다.", e);
        }
    }
}
