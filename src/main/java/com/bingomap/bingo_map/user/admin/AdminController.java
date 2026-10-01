package com.bingomap.bingo_map.user.admin;

import com.bingomap.bingo_map.map.WasteBinService;
import com.bingomap.bingo_map.restaurant.RestaurantRepository;
import com.bingomap.bingo_map.user.LoginController;
import com.bingomap.bingo_map.user.User;
import com.bingomap.bingo_map.user.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@Controller
public class AdminController {

    private static final DateTimeFormatter JOINED_FORMAT =
            DateTimeFormatter.ofPattern("yyyy.MM.dd");
    private static final DateTimeFormatter BLOCKED_UNTIL_FORMAT =
            DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm");

    private final UserRepository userRepository;
    private final RestaurantRepository restaurantRepository;
    private final WasteBinService wasteBinService;

    public AdminController(
            UserRepository userRepository,
            RestaurantRepository restaurantRepository,
            WasteBinService wasteBinService
    ) {
        this.userRepository = userRepository;
        this.restaurantRepository = restaurantRepository;
        this.wasteBinService = wasteBinService;
    }

    // 관리자 페이지 진입
    @GetMapping("/admin")
    public String admin(HttpServletRequest request) {
        if (!canAccessConsole(request)) {
            return redirectDenied(request);
        }

        return "forward:/admin/admin.html";
    }

    // 관리자 대시보드 통계 API
    @GetMapping("/api/admin/dashboard")
    @ResponseBody
    public AdminDashboardResponseDto dashboard(
            HttpServletRequest request
    ) {
        if (!canAccessConsole(request)) {
            return null;
        }

        long memberCount = userRepository.count();
        long restaurantCount = restaurantRepository.count();
        long binCount = wasteBinService.getWasteBins().size();

        // 최종 DB에는 제보/신고 테이블이 없으므로 0
        long pendingReportCount = 0;

        return new AdminDashboardResponseDto(
                memberCount,
                binCount,
                restaurantCount,
                pendingReportCount
        );
    }

    // 전체 회원 목록 조회
    @GetMapping("/api/admin/users")
    @ResponseBody
    public ResponseEntity<?> users(
            @RequestParam(required = false) String keyword,
            HttpServletRequest request
    ) {
        if (!canAccessConsole(request)) {
            return ResponseEntity
                    .status(403)
                    .body(
                            Map.of(
                                    "message",
                                    "관리자만 접근할 수 있습니다."
                            )
                    );
        }

        LocalDateTime now = LocalDateTime.now();
        String normalizedKeyword = keyword == null ? "" : keyword.trim().toLowerCase();
        List<AdminUserDto> result = userRepository.findAll().stream()
                .filter(u -> normalizedKeyword.isEmpty()
                        || String.valueOf(u.getUserId()).contains(normalizedKeyword)
                        || (u.getEmail() != null && u.getEmail().toLowerCase().contains(normalizedKeyword))
                        || (u.getNickname() != null && u.getNickname().toLowerCase().contains(normalizedKeyword)))
                .map(u -> {
                    boolean blocked = u.isCurrentlyBlocked(now);
                    boolean permanent = blocked && u.isBlockedPermanently();
                    String until = blocked && !permanent && u.getBlockedUntil() != null
                            ? u.getBlockedUntil().format(BLOCKED_UNTIL_FORMAT)
                            : null;
                    return new AdminUserDto(
                            u.getUserId(),
                            u.getName(),
                            u.getNickname(),
                            u.getEmail(),
                            u.getRole(),
                            u.getCreatedAt() != null ? u.getCreatedAt().format(JOINED_FORMAT) : "-",
                            blocked,
                            permanent,
                            until
                    );
                })
                .toList();

        return ResponseEntity.ok(result);
    }

    // 회원 권한 변경
    @PutMapping("/api/admin/users/{userId}/role")
    @ResponseBody
    public ResponseEntity<?> updateRole(
            @PathVariable Long userId,
            @Valid @RequestBody AdminRoleUpdateDto dto,
            BindingResult bindingResult,
            HttpServletRequest request
    ) {
        if (!isAdmin(request)) {
            return ResponseEntity
                    .status(403)
                    .body(
                            Map.of(
                                    "message",
                                    "관리자만 접근할 수 있습니다."
                            )
                    );
        }

        if (bindingResult.hasErrors()) {
            return ResponseEntity
                    .badRequest()
                    .body(
                            Map.of(
                                    "message",
                                    bindingResult
                                            .getFieldErrors()
                                            .get(0)
                                            .getDefaultMessage()
                            )
                    );
        }

        HttpSession session =
                request.getSession(false);

        Long myUserId =
                (Long) session.getAttribute(
                        LoginController.SESSION_USER_ID
                );

        if (userId.equals(myUserId)) {
            return ResponseEntity
                    .badRequest()
                    .body(
                            Map.of(
                                    "message",
                                    "본인의 권한은 스스로 변경할 수 없습니다."
                            )
                    );
        }

        User target =
                userRepository.findById(userId)
                        .orElse(null);

        if (target == null) {
            return ResponseEntity
                    .status(404)
                    .body(
                            Map.of(
                                    "message",
                                    "존재하지 않는 회원입니다."
                            )
                    );
        }

        if ("ADMIN".equals(target.getRole()) && !"ADMIN".equals(dto.getRole())
                && userRepository.findAll().stream().filter(u -> "ADMIN".equals(u.getRole())).count() <= 1) {
            return ResponseEntity.badRequest().body(Map.of("message", "마지막 관리자의 권한은 내릴 수 없습니다."));
        }

        target.setRole(dto.getRole());
        userRepository.save(target);

        return ResponseEntity.ok(
                Map.of(
                        "message",
                        "변경되었습니다."
                )
        );
    }

    // 회원 차단 기간 설정 (1일 / 7일 / 30일 / 영구)
    @PutMapping("/api/admin/users/{userId}/block")
    @ResponseBody
    public ResponseEntity<?> blockUser(
            @PathVariable Long userId,
            @RequestBody Map<String, String> body,
            HttpServletRequest request
    ) {
        if (!canAccessConsole(request)) {
            return ResponseEntity.status(403).body(Map.of("message", "관리자만 접근할 수 있습니다."));
        }

        HttpSession session = request.getSession(false);
        Long adminId = (Long) session.getAttribute(LoginController.SESSION_USER_ID);
        if (userId.equals(adminId)) {
            return ResponseEntity.badRequest().body(Map.of("message", "본인 계정은 차단할 수 없습니다."));
        }

        User target = userRepository.findById(userId).orElse(null);
        if (target == null) {
            return ResponseEntity.status(404).body(Map.of("message", "존재하지 않는 회원입니다."));
        }
        if ("ADMIN".equals(target.getRole())) {
            return ResponseEntity.badRequest().body(Map.of("message", "관리자 계정은 차단할 수 없습니다."));
        }

        LocalDateTime now = LocalDateTime.now();
        String duration = body.get("duration");
        switch (duration == null ? "" : duration) {
            case "1" -> target.blockUntil(now.plusDays(1));
            case "7" -> target.blockUntil(now.plusDays(7));
            case "30" -> target.blockUntil(now.plusDays(30));
            case "PERMANENT" -> target.blockPermanently();
            default -> {
                return ResponseEntity.badRequest().body(Map.of("message", "차단 기간이 올바르지 않습니다."));
            }
        }

        userRepository.save(target);
        return ResponseEntity.ok(Map.of("message", "회원 차단 기간을 설정했습니다."));
    }

    // 차단 해제
    @DeleteMapping("/api/admin/users/{userId}/block")
    @ResponseBody
    public ResponseEntity<?> unblockUser(
            @PathVariable Long userId,
            HttpServletRequest request
    ) {
        if (!canAccessConsole(request)) {
            return ResponseEntity.status(403).body(Map.of("message", "관리자만 접근할 수 있습니다."));
        }

        User target = userRepository.findById(userId).orElse(null);
        if (target == null) {
            return ResponseEntity.status(404).body(Map.of("message", "존재하지 않는 회원입니다."));
        }

        target.unblock();
        userRepository.save(target);
        return ResponseEntity.ok(Map.of("message", "회원 차단을 해제했습니다."));
    }

    // 회원 삭제
    @DeleteMapping("/api/admin/users/{userId}")
    @ResponseBody
    public ResponseEntity<?> deleteUser(
            @PathVariable Long userId,
            HttpServletRequest request
    ) {
        if (!canAccessConsole(request)) {
            return ResponseEntity
                    .status(403)
                    .body(
                            Map.of(
                                    "message",
                                    "관리자만 접근할 수 있습니다."
                            )
                    );
        }

        HttpSession session =
                request.getSession(false);

        Long myUserId =
                (Long) session.getAttribute(
                        LoginController.SESSION_USER_ID
                );

        if (userId.equals(myUserId)) {
            return ResponseEntity
                    .badRequest()
                    .body(
                            Map.of(
                                    "message",
                                    "본인 계정은 스스로 삭제할 수 없습니다."
                            )
                    );
        }

        if (!userRepository.existsById(userId)) {
            return ResponseEntity
                    .status(404)
                    .body(
                            Map.of(
                                    "message",
                                    "존재하지 않는 회원입니다."
                            )
                    );
        }

        User target = userRepository.findById(userId).orElse(null);
        if (isManager(request) && target != null && "ADMIN".equals(target.getRole())) {
            return ResponseEntity.status(403).body(Map.of("message", "매니저는 관리자 계정을 삭제할 수 없습니다."));
        }

        userRepository.deleteById(userId);

        return ResponseEntity.ok(
                Map.of(
                        "message",
                        "삭제되었습니다."
                )
        );
    }

    private boolean isAdmin(
            HttpServletRequest request
    ) {
        HttpSession session =
                request.getSession(false);

        return session != null
                && "ADMIN".equals(
                session.getAttribute(
                        LoginController.SESSION_USER_ROLE
                )
        );
    }

    @GetMapping("/api/admin/access")
    @ResponseBody
    public ResponseEntity<?> consoleAccess(HttpServletRequest request) {
        if (!canAccessConsole(request)) {
            return ResponseEntity.status(403).body(Map.of("message", "관리자 또는 매니저만 접근할 수 있습니다."));
        }
        HttpSession session = request.getSession(false);
        return ResponseEntity.ok(Map.of("role", session.getAttribute(LoginController.SESSION_USER_ROLE)));
    }

    private boolean isManager(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && "MANAGER".equals(session.getAttribute(LoginController.SESSION_USER_ROLE));
    }

    private boolean canAccessConsole(HttpServletRequest request) {
        return isAdmin(request) || isManager(request);
    }

    private String redirectDenied(
            HttpServletRequest request
    ) {
        HttpSession session =
                request.getSession(false);

        String message;

        if (session == null
                || session.getAttribute(
                LoginController.SESSION_USER_ID
        ) == null) {

            message = "로그인이 필요한 페이지입니다.";

        } else {
            message = "관리자만 접근할 수 있는 페이지입니다.";
        }

        return "redirect:/login?error="
                + URLEncoder.encode(
                message,
                StandardCharsets.UTF_8
        );
    }
}
