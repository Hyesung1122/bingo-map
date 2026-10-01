package com.bingomap.bingo_map.user;

import com.bingomap.bingo_map.community.CommunityComment;
import com.bingomap.bingo_map.community.CommunityCommentRepository;
import com.bingomap.bingo_map.community.CommunityPost;
import com.bingomap.bingo_map.community.CommunityPostRepository;
import com.bingomap.bingo_map.entity.TargetType;
import com.bingomap.bingo_map.report.BinReportRepository;
import com.bingomap.bingo_map.restaurant.Restaurant;
import com.bingomap.bingo_map.restaurant.RestaurantRepository;
import com.bingomap.bingo_map.review.Review;
import com.bingomap.bingo_map.review.ReviewImage;
import com.bingomap.bingo_map.review.ReviewRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Controller
public class MyPageController {

    private static final DateTimeFormatter JOINED_FORMAT = DateTimeFormatter.ofPattern("yyyy.MM.dd");

    private final UserRepository userRepository;
    private final ReviewRepository reviewRepository;
    private final RestaurantRepository restaurantRepository;
    private final BinReportRepository binReportRepository;
    private final CommunityPostRepository communityPostRepository;
    private final CommunityCommentRepository communityCommentRepository;

    public MyPageController(UserRepository userRepository,
                            ReviewRepository reviewRepository,
                            RestaurantRepository restaurantRepository,
                            BinReportRepository binReportRepository,
                            CommunityPostRepository communityPostRepository,
                            CommunityCommentRepository communityCommentRepository) {
        this.userRepository = userRepository;
        this.reviewRepository = reviewRepository;
        this.restaurantRepository = restaurantRepository;
        this.binReportRepository = binReportRepository;
        this.communityPostRepository = communityPostRepository;
        this.communityCommentRepository = communityCommentRepository;
    }

    // 마이페이지 화면 진입: 로그인 안 되어있으면 로그인 페이지로 돌려보냄
    @GetMapping("/mypage")
    public String mypage(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute(LoginController.SESSION_USER_ID) == null) {
            String message = URLEncoder.encode("로그인이 필요한 페이지입니다.", StandardCharsets.UTF_8);
            return "redirect:/login?error=" + message;
        }
        return "forward:/mypage/mypage.html";
    }

    // 마이페이지 프로필 정보 API (mypage.js가 호출)
    @GetMapping("/api/mypage/me")
    @ResponseBody
    public MyPageResponseDto me(HttpServletRequest request) {
        User user = currentUser(request);
        if (user == null) {
            return null;
        }
        return toDto(user);
    }

    // 마이페이지 통계 카드 API (작성한 게시글 / 댓글 / 리뷰 / 제보 수). 카드를 누르면 해당 탭 전체 목록으로 이동한다.
    @GetMapping("/api/mypage/stats")
    @ResponseBody
    public ResponseEntity<?> stats(HttpServletRequest request) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));
        }
        return ResponseEntity.ok(new MyPageStatsDto(communityPostRepository.countByUserId(userId),
                communityCommentRepository.countByUserId(userId),
                reviewRepository.countByUserId(userId),
                binReportRepository.countByUserId(userId)));
    }

    // 작성한 게시글 목록 API (최신순)
    @GetMapping("/api/mypage/posts")
    @ResponseBody
    public ResponseEntity<?> myPosts(HttpServletRequest request) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));
        }

        List<MyPostResponseDto> result = communityPostRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(this::toMyPostDto)
                .toList();
        return ResponseEntity.ok(result);
    }

    // 작성한 댓글 목록 API (최신순). 어느 글에 단 댓글인지 제목을 같이 내려준다.
    @GetMapping("/api/mypage/comments")
    @ResponseBody
    public ResponseEntity<?> myComments(HttpServletRequest request) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));
        }

        List<CommunityComment> comments = communityCommentRepository.findByUserIdOrderByCreatedAtDesc(userId);

        Set<Long> postIds = comments.stream().map(CommunityComment::getPostId).collect(Collectors.toSet());
        Map<Long, String> titleByPostId = new HashMap<>();
        for (CommunityPost post : communityPostRepository.findAllById(postIds)) {
            titleByPostId.put(post.getPostId(), post.getTitle());
        }

        List<MyCommentResponseDto> result = comments.stream()
                .map(c -> new MyCommentResponseDto(
                        c.getCommentId(), c.getPostId(),
                        titleByPostId.getOrDefault(c.getPostId(), "삭제된 글"),
                        c.getContent(),
                        c.getCreatedAt() != null ? c.getCreatedAt().format(JOINED_FORMAT) : "-",
                        "/community/" + c.getPostId()))
                .toList();
        return ResponseEntity.ok(result);
    }

    private MyPostResponseDto toMyPostDto(CommunityPost post) {
        String content = post.getContent() != null ? post.getContent() : "";
        String preview = content.length() > 80 ? content.substring(0, 80) + "..." : content;
        String createdAt = post.getCreatedAt() != null ? post.getCreatedAt().format(JOINED_FORMAT) : "-";
        return new MyPostResponseDto(post.getPostId(), post.getTitle(), preview,
                post.getViewCount(), createdAt, "/community/" + post.getPostId());
    }

    // 내가 쓴 리뷰 목록 API (최신순). 맛집 이름은 이 목록에 나온 맛집만 한 번에 조회한다.
    @GetMapping("/api/mypage/reviews")
    @ResponseBody
    @Transactional(readOnly = true)
    public ResponseEntity<?> myReviews(HttpServletRequest request) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));
        }

        List<Review> reviews = reviewRepository.findByUserIdOrderByCreatedAtDesc(userId);

        // 리뷰 대상이 맛집(RESTAURANT)인 것만 이름 조회 (대상 ID가 숫자인 경우만)
        Set<Long> restaurantIds = reviews.stream()
                .filter(r -> TargetType.RESTAURANT.name().equals(r.getTargetType()))
                .map(r -> toLong(r.getTargetId()))
                .filter(id -> id != null)
                .collect(Collectors.toSet());
        Map<Long, String> restaurantNames = new HashMap<>();
        for (Restaurant restaurant : restaurantRepository.findAllById(restaurantIds)) {
            restaurantNames.put(restaurant.getRestaurantId(), restaurant.getName());
        }

        List<MyReviewResponseDto> result = reviews.stream()
                .map(r -> toMyReviewDto(r, restaurantNames))
                .toList();
        return ResponseEntity.ok(result);
    }

    // 마이페이지에서 본인이 작성한 리뷰만 삭제
    @DeleteMapping("/api/mypage/reviews/{reviewId:\\d+}")
    @ResponseBody
    @Transactional
    public ResponseEntity<Void> deleteMyReview(@PathVariable Long reviewId, HttpServletRequest request) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }

        Review review = reviewRepository.findById(reviewId).orElse(null);
        if (review == null) {
            return ResponseEntity.notFound().build();
        }
        if (!userId.equals(review.getUserId())) {
            return ResponseEntity.status(403).build();
        }

        reviewRepository.delete(review);
        return ResponseEntity.noContent().build();
    }

    // 프로필 수정 API (이름/닉네임/국적만 수정 가능. 이메일은 로그인 계정 정보라 제외)
    @PutMapping("/api/mypage/me")
    @ResponseBody
    public ResponseEntity<?> updateMe(@Valid @RequestBody MyPageUpdateRequestDto dto,
                                      BindingResult bindingResult,
                                      HttpServletRequest request) {
        User user = currentUser(request);
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));
        }

        if (bindingResult.hasErrors()) {
            String message = bindingResult.getFieldErrors().get(0).getDefaultMessage();
            return ResponseEntity.badRequest().body(Map.of("message", message));
        }

        // 닉네임을 바꾸려는 경우에만 중복 체크 (자기 자신의 기존 닉네임이면 통과)
        if (!dto.getNickname().equals(user.getNickname())
                && userRepository.existsByNickname(dto.getNickname())) {
            return ResponseEntity.badRequest().body(Map.of("message", "이미 사용 중인 닉네임입니다."));
        }

        user.setName(dto.getName());
        user.setNickname(dto.getNickname());
        user.setNationality(dto.getNationality());
        userRepository.save(user);

        // 세션에 저장된 이름도 최신화 (헤더에 표시되는 이름이 안 바뀌는 걸 방지)
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.setAttribute(LoginController.SESSION_USER_NAME, user.getName());
        }

        return ResponseEntity.ok(toDto(user));
    }

    // 설정(알림/위치정보) 조회
    @GetMapping("/api/mypage/settings")
    @ResponseBody
    public ResponseEntity<?> getSettings(HttpServletRequest request) {
        User user = currentUser(request);
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));
        }
        return ResponseEntity.ok(new UserSettingsResponseDto(user.isNotifyEmail(), user.isLocationEnabled()));
    }

    // 설정(알림/위치정보) 저장
    @PutMapping("/api/mypage/settings")
    @ResponseBody
    public ResponseEntity<?> updateSettings(@RequestBody UserSettingsUpdateDto dto, HttpServletRequest request) {
        User user = currentUser(request);
        if (user == null) {
            return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));
        }

        user.setNotifyEmail(dto.isNotifyEmail() ? "Y" : "N");
        user.setLocationEnabled(dto.isLocationEnabled() ? "Y" : "N");
        userRepository.save(user);

        return ResponseEntity.ok(new UserSettingsResponseDto(user.isNotifyEmail(), user.isLocationEnabled()));
    }

    private MyReviewResponseDto toMyReviewDto(Review review, Map<Long, String> restaurantNames) {
        Long restaurantId = null;
        String name;
        if (TargetType.RESTAURANT.name().equals(review.getTargetType())) {
            restaurantId = toLong(review.getTargetId());
            name = restaurantId != null
                    ? restaurantNames.getOrDefault(restaurantId, "삭제된 맛집")
                    : "맛집";
        } else {
            name = "쓰레기통 리뷰";
        }

        String thumbnail = review.getImages().stream()
                .map(ReviewImage::getImageUrl)
                .filter(url -> url != null && !url.isBlank())
                .findFirst()
                .orElse(null);
        String createdAt = review.getCreatedAt() != null ? review.getCreatedAt().format(JOINED_FORMAT) : "-";

        return new MyReviewResponseDto(
                review.getReviewId(), restaurantId, name, review.getRating(),
                review.getContent() != null ? review.getContent() : "",
                createdAt,
                review.getHelpCount() != null ? review.getHelpCount() : 0,
                thumbnail,
                "/reviews/" + review.getReviewId());
    }

    private Long toLong(String value) {
        try {
            return value == null ? null : Long.valueOf(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Long currentUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (Long) session.getAttribute(LoginController.SESSION_USER_ID);
    }

    private User currentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute(LoginController.SESSION_USER_ID) == null) {
            return null;
        }
        Long userId = (Long) session.getAttribute(LoginController.SESSION_USER_ID);
        return userRepository.findById(userId).orElse(null);
    }

    private MyPageResponseDto toDto(User user) {
        String joinedAt = user.getCreatedAt() != null ? user.getCreatedAt().format(JOINED_FORMAT) : "-";
        String nationality = (user.getNationality() != null && !user.getNationality().isBlank())
                ? user.getNationality() : "미입력";
        return new MyPageResponseDto(user.getName(), user.getNickname(), user.getEmail(), nationality, joinedAt, user.getRole());
    }
}
