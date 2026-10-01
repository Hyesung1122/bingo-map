package com.bingomap.bingo_map.review;

import com.bingomap.bingo_map.notification.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import com.bingomap.bingo_map.restaurant.RestaurantSummaryDto;
import com.bingomap.bingo_map.user.LoginController;
import com.bingomap.bingo_map.user.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
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
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class ReviewService {

    private static final int MAX_IMAGE_COUNT = 5;

    private static final Path UPLOAD_DIR =
            Paths.get("uploads", "reviews");

    private static final String TARGET_RESTAURANT = "RESTAURANT";

    private final ReviewRepository reviewRepository;

    private final JdbcTemplate jdbc;
    private final HttpServletRequest httpRequest;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private UserRepository userRepository;   // [10/01 유해성] 작성자 닉네임 표시용 (읽기만)

    // [10/01 유해성] "도움이 돼요"를 누른 리뷰 번호를 회원별로 기억 (DB 없이 서버 메모리).
    // 같은 회원은 한 리뷰에 한 번만, 다시 누르면 취소. 서버를 재시작하면 기록이 초기화됨.
    private static final Map<Long, Set<Long>> HELPED_BY_USER = new ConcurrentHashMap<>();

    // [10/01 유해성] PR #20 병합 때 예전 버전으로 덮어써져 빠진 로그인 작성자 / 본인 확인 /
    // 별점 검증 / 맛집 평점 갱신을 복구하고, 새로 추가된 알림 기능은 유지
    public ReviewService(ReviewRepository reviewRepository, JdbcTemplate jdbc,
                         HttpServletRequest httpRequest) {
        this.reviewRepository = reviewRepository;
        this.jdbc = jdbc;
        this.httpRequest = httpRequest;
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
                .map(this::decorate)
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
                        .map(this::decorate)
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
        return decorate(new ReviewResponseDto(
                findReviewOrThrow(reviewId)
        ));
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

        // 사용자 번호는 요청 본문 대신 로그인 세션에서 결정합니다.
        Long authorId = requireUserId();
        validateRating(request.getRating());
        targetId = normalizeTargetId(targetType, targetId);
        lockRestaurant(targetType, targetId, true);

        Review review = new Review(
                authorId,
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

        Review saved = reviewRepository.saveAndFlush(review);
        refreshRestaurantRating(saved.getTargetType(), saved.getTargetId());

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

        requireAuthor(review);   // [10/01 유해성] 수정은 작성자 본인만 (관리자 불가, 삭제는 관리자 가능)
        validateRating(request.getRating());
        lockRestaurant(review.getTargetType(), review.getTargetId(), false);
        review.edit(
                request.getRating(),
                request.getContent(),
                request.getVisitDate(),
                request.getVisitTimeSlot(),
                request.getVisitPurpose(),
                request.getRecommendYn()
        );

        reviewRepository.flush();
        refreshRestaurantRating(review.getTargetType(), review.getTargetId());
        return new ReviewResponseDto(review);
    }

    /**
     * 리뷰 삭제.
     */
    @Transactional
    public void delete(Long reviewId) {

        Review review =
                findReviewOrThrow(reviewId);

        requireOwner(review);
        lockRestaurant(review.getTargetType(), review.getTargetId(), false);

        // [10/01 유해성] 지울 사진 주소를 미리 받아 둠 (DB 삭제 후엔 목록을 못 읽음)
        List<String> imageUrls = review.getImages().stream()
                .map(ReviewImage::getImageUrl)
                .collect(Collectors.toList());

        reviewRepository.delete(review);
        reviewRepository.flush();
        refreshRestaurantRating(review.getTargetType(), review.getTargetId());

        deleteImageFilesAfterCommit(imageUrls);
    }

    /**
     * [10/01 유해성] DB 삭제가 확정(커밋)된 뒤에 uploads/reviews 의 사진 파일을 지움.
     * DB 삭제가 실패하면 파일은 그대로 두고, 파일 삭제가 실패해도 리뷰 삭제는 성공으로 둠.
     */
    private void deleteImageFilesAfterCommit(List<String> imageUrls) {
        if (imageUrls.isEmpty()) {
            return;
        }
        Runnable deleteFiles = () -> imageUrls.forEach(this::deleteImageFile);

        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    deleteFiles.run();
                }
            });
        } else {
            deleteFiles.run();
        }
    }

    // "/uploads/reviews/파일명" 만 지움. 폴더 밖 경로는 무시
    private void deleteImageFile(String imageUrl) {
        String prefix = "/uploads/reviews/";
        if (imageUrl == null || !imageUrl.startsWith(prefix)) {
            return;
        }
        Path dir = UPLOAD_DIR.toAbsolutePath().normalize();
        Path file = dir.resolve(imageUrl.substring(prefix.length())).normalize();
        if (!file.startsWith(dir) || file.equals(dir)) {
            return;
        }
        try {
            Files.deleteIfExists(file);
        } catch (IOException | RuntimeException e) {
            // 파일 정리 실패는 리뷰 삭제 결과에 영향 주지 않음
        }
    }

    /**
     * 도움이 돼요.
     * [10/01 유해성] 로그인 필요, 한 회원당 한 번만. 이미 눌렀으면 취소(-1).
     */
    @Transactional
    public ReviewResponseDto markHelpful(Long reviewId) {

        Long userId = requireUserId();
        Review review =
                findReviewOrThrow(reviewId);

        Set<Long> helped = HELPED_BY_USER.computeIfAbsent(userId, k -> ConcurrentHashMap.newKeySet());
        if (helped.remove(reviewId)) {
            review.unmarkHelpful();
        } else {
            helped.add(reviewId);
            review.markHelpful();
        }

        return decorate(new ReviewResponseDto(review));
    }

    // [10/01 유해성] 응답에 작성자 닉네임과 "내가 도움이 돼요를 눌렀는지"를 채움
    private ReviewResponseDto decorate(ReviewResponseDto dto) {
        dto.setAuthorName(userRepository.findById(dto.getUserId())
                .map(u -> u.getNickname() != null && !u.getNickname().isBlank() ? u.getNickname()
                        : u.getName() != null && !u.getName().isBlank() ? u.getName()
                        : "회원" + dto.getUserId())
                .orElse("회원" + dto.getUserId()));

        Long loginUserId = ReviewController.sessionUserId(httpRequest);
        dto.setHelped(loginUserId != null
                && HELPED_BY_USER.getOrDefault(loginUserId, Set.of()).contains(dto.getReviewId()));
        return dto;
    }

    private Long requireUserId() {
        Long userId = ReviewController.sessionUserId(httpRequest);
        if (userId == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "로그인이 필요합니다.");
        }
        return userId;
    }

    private void requireOwner(Review review) {
        Long userId = requireUserId();
        Object role = httpRequest.getSession(false).getAttribute(LoginController.SESSION_USER_ROLE);
        if (!userId.equals(review.getUserId()) && !"ADMIN".equals(role)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "본인이 작성한 리뷰만 수정·삭제할 수 있습니다.");
        }
    }

    // [10/01 유해성] 작성자 본인만 (관리자도 남의 리뷰는 수정 불가)
    private void requireAuthor(Review review) {
        Long userId = requireUserId();
        if (!userId.equals(review.getUserId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "본인이 작성한 리뷰만 수정할 수 있습니다.");
        }
    }

    private static void validateRating(Double rating) {
        if (rating == null || !Double.isFinite(rating) || rating < 0.5 || rating > 5.0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "평점은 0.5~5점으로 입력해주세요.");
        }
    }

    private static String normalizeTargetId(String type, String targetId) {
        if (!TARGET_RESTAURANT.equals(type) && !"WASTE_BIN".equals(type)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "리뷰 대상 종류가 올바르지 않습니다.");
        }
        if (!TARGET_RESTAURANT.equals(type)) return targetId.trim();
        try {
            long id = Long.parseLong(targetId.trim());
            if (id <= 0) throw new NumberFormatException();
            return Long.toString(id);
        } catch (NumberFormatException e) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "식당 번호가 올바르지 않습니다.");
        }
    }

    /** 같은 식당의 동시 리뷰 변경을 순서대로 처리해 집계 누락을 막습니다. */
    private void lockRestaurant(String type, String targetId, boolean requirePublished) {
        if (!TARGET_RESTAURANT.equals(type)) return;
        String sql = "SELECT RESTAURANT_ID FROM RESTAURANTS WHERE RESTAURANT_ID = ?"
                + (requirePublished ? " AND IS_PUBLISHED = 'Y'" : "") + " FOR UPDATE";
        List<Long> ids = jdbc.queryForList(sql, Long.class, Long.valueOf(targetId));
        if (ids.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "리뷰를 작성할 식당을 찾을 수 없습니다.");
        }
    }

    /** 리뷰 저장/수정/삭제와 같은 트랜잭션에서 기존 식당 조회용 집계값도 맞춥니다. */
    private void refreshRestaurantRating(String type, String targetId) {
        if (!TARGET_RESTAURANT.equals(type)) return;
        jdbc.update("""
                UPDATE RESTAURANTS R
                SET (RATING, REVIEW_COUNT) = (
                    SELECT ROUND(AVG(V.RATING), 1), COUNT(*)
                    FROM REVIEWS V
                    WHERE V.TARGET_TYPE = 'RESTAURANT' AND V.TARGET_ID = ?
                )
                WHERE R.RESTAURANT_ID = ?
                """, targetId, Long.valueOf(targetId));
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