package com.bingomap.bingo_map.report;

import com.bingomap.bingo_map.notification.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
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

import java.util.Comparator;
import java.util.List;
import java.util.Map;

@Controller
public class AdminReportController {

    private final BinReportRepository binReportRepository;
    private final UserRepository userRepository;

    @Autowired
    private NotificationService notificationService;

    public AdminReportController(BinReportRepository binReportRepository, UserRepository userRepository) {
        this.binReportRepository = binReportRepository;
        this.userRepository = userRepository;
    }

    // 전체 제보 목록 (보류인 것이 위로 오도록 정렬 후 최신순)
    @GetMapping("/api/admin/reports")
    @ResponseBody
    public ResponseEntity<?> reports(HttpServletRequest request) {
        if (!canManageReports(request)) {
            return ResponseEntity.status(403).body(Map.of("message", "관리자만 접근할 수 있습니다."));
        }

        List<BinReport> reports = binReportRepository.findAllByOrderByCreatedAtDesc().stream()
                .sorted(Comparator.comparing(AdminReportController::statusOrder))
                .toList();

        List<BinReportResponseDto> result = reports.stream()
                .map(r -> {
                    BinReportResponseDto dto = new BinReportResponseDto(r);
                    User reporter = userRepository.findById(r.getUserId()).orElse(null);
                    if (reporter != null) {
                        dto.setReporter(reporter.getName(), reporter.getNickname());
                    } else {
                        dto.setReporter("탈퇴한 회원", "-");
                    }
                    return dto;
                })
                .toList();

        return ResponseEntity.ok(result);
    }

    // 관리자 알림용: 검수 대기(PENDING) 제보 수 (헤더 배지/알림 토스트가 주기적으로 호출)
    @GetMapping("/api/admin/reports/pending-count")
    @ResponseBody
    public ResponseEntity<?> pendingCount(HttpServletRequest request) {
        if (!canManageReports(request)) {
            return ResponseEntity.status(403).body(Map.of("message", "관리자만 접근할 수 있습니다."));
        }
        return ResponseEntity.ok(Map.of("count", binReportRepository.countByStatus(BinReport.STATUS_PENDING)));
    }

    // 보류(PENDING)가 맨 위, 그다음 승인/반려 순으로 보여주기 위한 정렬 우선순위
    private static int statusOrder(BinReport r) {
        return switch (r.getStatus()) {
            case BinReport.STATUS_PENDING -> 0;
            case BinReport.STATUS_APPROVED -> 1;
            default -> 2;
        };
    }

    // 제보 검수 처리: 보류로 되돌리기 / 승인 / 반려(사유 포함)
    @PutMapping("/api/admin/reports/{reportId}/status")
    @ResponseBody
    public ResponseEntity<?> updateStatus(@PathVariable Long reportId,
                                          @Valid @RequestBody BinReportStatusUpdateDto dto,
                                          BindingResult bindingResult,
                                          HttpServletRequest request) {
        if (!canManageReports(request)) {
            return ResponseEntity.status(403).body(Map.of("message", "관리자만 접근할 수 있습니다."));
        }
        if (bindingResult.hasErrors()) {
            return ResponseEntity.badRequest().body(Map.of("message", bindingResult.getFieldErrors().get(0).getDefaultMessage()));
        }
        if (BinReport.STATUS_REJECTED.equals(dto.getStatus())
                && (dto.getRejectReason() == null || dto.getRejectReason().isBlank())) {
            return ResponseEntity.badRequest().body(Map.of("message", "반려 사유를 입력해주세요."));
        }

        BinReport report = binReportRepository.findById(reportId).orElse(null);
        if (report == null) {
            return ResponseEntity.status(404).body(Map.of("message", "존재하지 않는 제보입니다."));
        }

        Long adminId = (Long) request.getSession(false).getAttribute(LoginController.SESSION_USER_ID);
        String previousStatus = report.getStatus();
        report.review(dto.getStatus(), dto.getRejectReason(), adminId);
        binReportRepository.save(report);
        notificationService.onReportReviewed(report.getUserId(), report.getName(),
                previousStatus, report.getStatus(), report.getRejectReason());

        return ResponseEntity.ok(Map.of("message", "처리되었습니다."));
    }

    // 제보 삭제 (관리자 페이지의 삭제 버튼이 호출)
    @DeleteMapping("/api/admin/reports/{reportId}")
    @ResponseBody
    public ResponseEntity<?> deleteReport(@PathVariable Long reportId, HttpServletRequest request) {
        if (!canManageReports(request)) {
            return ResponseEntity.status(403).body(Map.of("message", "관리자만 접근할 수 있습니다."));
        }
        if (!binReportRepository.existsById(reportId)) {
            return ResponseEntity.status(404).body(Map.of("message", "존재하지 않는 제보입니다."));
        }
        binReportRepository.deleteById(reportId);
        return ResponseEntity.ok(Map.of("message", "삭제되었습니다."));
    }

    private boolean canManageReports(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        Object role = session.getAttribute(LoginController.SESSION_USER_ROLE);
        return "ADMIN".equals(role) || "MANAGER".equals(role);
    }
}
