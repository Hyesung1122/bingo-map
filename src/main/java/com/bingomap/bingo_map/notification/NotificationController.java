package com.bingomap.bingo_map.notification;

import com.bingomap.bingo_map.user.LoginController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 내 알림 API (로그인한 본인 것만)
 *  GET    /api/notifications?page=0&size=10   목록 + 안 읽은 수
 *  GET    /api/notifications/summary          헤더 종 아이콘용 (안 읽은 수, 최근 8개)
 *  POST   /api/notifications/{id}/read        읽음
 *  POST   /api/notifications/read-all         모두 읽음
 *  DELETE /api/notifications/{id}             삭제
 */
@RestController
public class NotificationController {

    private static final DateTimeFormatter DISPLAY = DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm");
    private static final DateTimeFormatter ISO = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");

    public record NotificationDto(Long id, String type, String message, String linkUrl,
                                  boolean read, String createdAt, String createdAtIso) {
        static NotificationDto from(Notification n) {
            return new NotificationDto(n.getId(), n.getType(), n.getMessage(), n.getLinkUrl(), n.isRead(),
                    n.getCreatedAt() != null ? n.getCreatedAt().format(DISPLAY) : "-",
                    n.getCreatedAt() != null ? n.getCreatedAt().format(ISO) : null);
        }
    }

    private final NotificationRepository repository;
    private final NotificationService service;

    public NotificationController(NotificationRepository repository, NotificationService service) {
        this.repository = repository;
        this.service = service;
    }

    @GetMapping("/api/notifications")
    public ResponseEntity<?> list(@RequestParam(defaultValue = "0") int page,
                                  @RequestParam(defaultValue = "10") int size,
                                  HttpServletRequest request) {
        Long userId = currentUserId(request);
        if (userId == null) return unauthorized();

        Page<Notification> result = repository.findByUserIdOrderByCreatedAtDescIdDesc(
                userId, PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 50)));

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("items", result.getContent().stream().map(NotificationDto::from).toList());
        body.put("page", result.getNumber());
        body.put("totalPages", result.getTotalPages());
        body.put("totalElements", result.getTotalElements());
        body.put("unreadCount", repository.countByUserIdAndIsRead(userId, "N"));
        return ResponseEntity.ok(body);
    }

    @GetMapping("/api/notifications/summary")
    public ResponseEntity<?> summary(HttpServletRequest request) {
        Long userId = currentUserId(request);
        if (userId == null) return unauthorized();

        List<NotificationDto> items = repository
                .findByUserIdOrderByCreatedAtDescIdDesc(userId, PageRequest.of(0, 8))
                .getContent().stream().map(NotificationDto::from).toList();

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("unreadCount", repository.countByUserIdAndIsRead(userId, "N"));
        body.put("latestId", items.stream().mapToLong(NotificationDto::id).max().orElse(0L));
        body.put("items", items);
        return ResponseEntity.ok(body);
    }

    @PostMapping("/api/notifications/{id:\\d+}/read")
    public ResponseEntity<?> read(@PathVariable Long id, HttpServletRequest request) {
        Long userId = currentUserId(request);
        if (userId == null) return unauthorized();
        if (!service.markRead(userId, id)) return notFound();
        return ResponseEntity.ok(Map.of("message", "읽음 처리되었습니다."));
    }

    @PostMapping("/api/notifications/read-all")
    public ResponseEntity<?> readAll(HttpServletRequest request) {
        Long userId = currentUserId(request);
        if (userId == null) return unauthorized();
        service.markAllRead(userId);
        return ResponseEntity.ok(Map.of("message", "모두 읽음 처리되었습니다."));
    }

    @DeleteMapping("/api/notifications/{id:\\d+}")
    public ResponseEntity<?> delete(@PathVariable Long id, HttpServletRequest request) {
        Long userId = currentUserId(request);
        if (userId == null) return unauthorized();
        if (!service.delete(userId, id)) return notFound();
        return ResponseEntity.ok(Map.of("message", "삭제되었습니다."));
    }

    private ResponseEntity<?> unauthorized() {
        return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));
    }

    private ResponseEntity<?> notFound() {
        return ResponseEntity.status(404).body(Map.of("message", "존재하지 않는 알림입니다."));
    }

    private Long currentUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        return (Long) session.getAttribute(LoginController.SESSION_USER_ID);
    }
}