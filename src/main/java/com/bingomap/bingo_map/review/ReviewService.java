package com.bingomap.bingo_map.review;

import com.bingomap.bingo_map.notification.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import com.bingomap.bingo_map.restaurant.RestaurantSummaryDto;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
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
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class ReviewService {

    private static final int MAX_IMAGE_COUNT = 5;

    private static final Path UPLOAD_DIR =
            Paths.get("uploads", "reviews");

    private static final String TARGET_RESTAURANT = "RESTAURANT";

    private final ReviewRepository reviewRepository;

    @Autowired
    private NotificationService notificationService;

    public ReviewService(ReviewRepository reviewRepository) {
        this.reviewRepository = reviewRepository;
    }

    /**
     * 기존 리뷰 화면 호환용.
     * restaurantId가 있으면 RESTAURANT 타입으로 조회한다.
     */
    public List<ReviewResponseDto> getReviews(Long restaurantId) {

        List<Review> reviews;

        if (restaurantId == null) {
            reviews = reviewRepository.findAllByOrderByCreatedAtDesc();
        } else {
            reviews = reviewRepository
                    .findByTargetTypeAndTargetIdOrderByCreatedAtDesc(
                            TARGET_RESTAURANT,
                            String.valueOf(restaurantId)
                    );
        }

        return reviews.stream()
                .map(ReviewResponseDto::new)
                .collect(Collectors.toList());
    }

    /**
     * 리뷰 목록 조회.
     * 검색 + 페이징 + 정렬.
     */
    public Page<ReviewResponseDto> getReviewsPage(
            String keyword,
            Pageable pageable
    ) {

        List<Review> all =
                (keyword == null || keyword.isBlank())
                        ? reviewRepository.findAllByOrderByCreatedAtDesc()
                        : reviewRepository.findByContentContainingIgnoreCase(
                        keyword,
                        pageable.getSort()
                );

        int start = (int) pageable.getOffset();

        if (start >= all.size()) {
            return new PageImpl<>(
                    List.of(),
                    pageable,
                    all.size()
            );
        }

        int end = Math.min(
                start + pageable.getPageSize(),
                all.size()
        );

        List<ReviewResponseDto> pageContent =
                all.subList(start, end)
                        .stream()
                        .map(ReviewResponseDto::new)
                        .collect(Collectors.toList());

        return new PageImpl<>(
                pageContent,
                pageable,
                all.size()
        );
    }

    /**
     * 맛집별 리뷰 요약 목록.
     *
     * 새 DB에서는 리뷰가 targetType + targetId 구조이므로
     * 전체 리뷰를 가져와 RESTAURANT 타입만 Java에서 묶는다.
     */
    public List<RestaurantSummaryDto> getRestaurantSummaries() {

        List<Review> allReviews =
                reviewRepository.findAllByOrderByCreatedAtDesc();

        Map<String, List<Review>> grouped =
                allReviews.stream()
                        .filter(review ->
                                TARGET_RESTAURANT.equals(
                                        review.getTargetType()
                                )
                        )
                        .filter(review ->
                                review.getTargetId() != null
                        )
                        .collect(
                                Collectors.groupingBy(
                                        Review::getTargetId,
                                        LinkedHashMap::new,
                                        Collectors.toList()
                                )
                        );

        return grouped.entrySet()
                .stream()
                .map(entry -> {

                    String targetId = entry.getKey();
                    List<Review> reviews = entry.getValue();

                    Long restaurantId;

                    try {
                        restaurantId = Long.valueOf(targetId);
                    } catch (NumberFormatException e) {
                        return null;
                    }

                    Long reviewCount =
                            (long) reviews.size();

                    Double avgRating =
                            reviews.stream()
                                    .map(Review::getRating)
                                    .filter(rating -> rating != null)
                                    .mapToDouble(Double::doubleValue)
                                    .average()
                                    .orElse(0.0);

                    Review latest =
                            reviews.stream()
                                    .max(
                                            Comparator.comparing(
                                                    Review::getCreatedAt,
                                                    Comparator.nullsLast(
                                                            Comparator.naturalOrder()
                                                    )
                                            )
                                    )
                                    .orElse(null);

                    String preview =
                            latest == null
                                    ? ""
                                    : latest.getContent();

                    String thumbnail =
                            reviews.stream()
                                    .flatMap(
                                            review ->
                                                    review.getImages().stream()
                                    )
                                    .map(ReviewImage::getImageUrl)
                                    .filter(url -> url != null)
                                    .findFirst()
                                    .orElse(null);

                    return new RestaurantSummaryDto(
                            restaurantId,
                            reviewCount,
                            avgRating,
                            preview,
                            thumbnail
                    );
                })
                .filter(result -> result != null)
                .sorted(
                        Comparator.comparing(
                                RestaurantSummaryDto::getReviewCount,
                                Comparator.reverseOrder()
                        )
                )
                .collect(Collectors.toList());
    }

    /**
     * 리뷰 상세 조회.
     */
    public ReviewResponseDto getReview(Long reviewId) {
        return new ReviewResponseDto(
                findReviewOrThrow(reviewId)
        );
    }

    /**
     * 리뷰 작성.
     *
     * 새 구조:
     * targetType = RESTAURANT / WASTE_BIN
     * targetId   = 대상 ID
     *
     * 기존 프론트가 restaurantId만 보내는 경우에는
     * RESTAURANT 타입으로 자동 변환한다.
     */
    @Transactional
    public ReviewResponseDto create(
            ReviewRequestDto request,
            List<MultipartFile> photos
    ) {

        String targetType = request.getTargetType();
        String targetId = request.getTargetId();

        if (targetType == null || targetType.isBlank()) {
            targetType = TARGET_RESTAURANT;
        }

        if (targetId == null || targetId.isBlank()) {

            if (request.getRestaurantId() != null) {
                targetId =
                        String.valueOf(
                                request.getRestaurantId()
                        );
            } else {
                throw new IllegalArgumentException(
                        "targetId가 필요합니다."
                );
            }
        }

        targetType =
                targetType.trim().toUpperCase();

        Review review = new Review(
                request.getUserId(),
                targetType,
                targetId,
                request.getRating(),
                request.getContent(),
                request.getVisitDate(),
                request.getVisitTimeSlot(),
                request.getVisitPurpose(),
                request.getRecommendYn()
        );

        attachImages(review, photos);

        Review saved =
                reviewRepository.save(review);

        notificationService.onReviewCreated(
                saved.getTargetType(), saved.getTargetId(), saved.getUserId(), saved.getReviewId());

        return new ReviewResponseDto(saved);
    }

    /**
     * 리뷰 수정.
     */
    @Transactional
    public ReviewResponseDto edit(
            Long reviewId,
            ReviewRequestDto request
    ) {

        Review review =
                findReviewOrThrow(reviewId);

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

    /**
     * 리뷰 삭제.
     */
    @Transactional
    public void delete(Long reviewId) {

        Review review =
                findReviewOrThrow(reviewId);

        reviewRepository.delete(review);
    }

    /**
     * 도움이 돼요 증가.
     */
    @Transactional
    public ReviewResponseDto markHelpful(Long reviewId) {

        Review review =
                findReviewOrThrow(reviewId);

        review.markHelpful();

        return new ReviewResponseDto(review);
    }

    private Review findReviewOrThrow(Long reviewId) {

        return reviewRepository
                .findById(reviewId)
                .orElseThrow(
                        () -> new EntityNotFoundException(
                                "리뷰를 찾을 수 없습니다. id="
                                        + reviewId
                        )
                );
    }

    private void attachImages(
            Review review,
            List<MultipartFile> photos
    ) {

        if (photos == null || photos.isEmpty()) {
            return;
        }

        int limit =
                Math.min(
                        photos.size(),
                        MAX_IMAGE_COUNT
                );

        for (int i = 0; i < limit; i++) {

            MultipartFile photo =
                    photos.get(i);

            if (photo == null || photo.isEmpty()) {
                continue;
            }

            String url =
                    storeFile(photo);

            review.addImage(
                    ReviewImage.upload(
                            url,
                            i
                    )
            );
        }
    }

    /**
     * 업로드 파일 저장.
     */
    private String storeFile(
            MultipartFile photo
    ) {

        try {

            Files.createDirectories(
                    UPLOAD_DIR
            );

            String original =
                    photo.getOriginalFilename() == null
                            ? ""
                            : photo.getOriginalFilename();

            String ext =
                    original.contains(".")
                            ? original.substring(
                            original.lastIndexOf('.')
                    )
                            : "";

            String fileName =
                    UUID.randomUUID()
                            + ext;

            Path target =
                    UPLOAD_DIR.resolve(fileName);

            try (InputStream in =
                         photo.getInputStream()) {

                Files.copy(
                        in,
                        target,
                        StandardCopyOption.REPLACE_EXISTING
                );
            }

            return "/uploads/reviews/"
                    + fileName;

        } catch (IOException e) {

            throw new IllegalStateException(
                    "리뷰 이미지 저장에 실패했습니다.",
                    e
            );
        }
    }
}