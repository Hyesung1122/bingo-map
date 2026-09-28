package com.bingomap.bingo_map.report;

import com.bingomap.bingo_map.user.LoginController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

@Controller
public class BinReportController {

    private final BinReportRepository binReportRepository;

    public BinReportController(BinReportRepository binReportRepository) {
        this.binReportRepository = binReportRepository;
    }

    // 제보 화면 진입: 로그인 안 되어있으면 로그인 페이지로 돌려보냄
    @GetMapping("/report")
    public String reportPage(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute(LoginController.SESSION_USER_ID) == null) {
            String message = URLEncoder.encode("로그인이 필요한 페이지입니다.", StandardCharsets.UTF_8);
            return "redirect:/login?error=" + message;
        }
        return "forward:/report/report.html";
    }

    // 제보 제출
    @PostMapping("/api/reports")
    @ResponseBody
    public ResponseEntity<?> submit(@Valid @RequestBody BinReportRequestDto dto,
                                    BindingResult bindingResult,
                                    HttpServletRequest request) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));
        }
        if (bindingResult.hasErrors()) {
            String message = bindingResult.getFieldErrors().get(0).getDefaultMessage();
            return ResponseEntity.badRequest().body(Map.of("message", message));
        }

        String category = (dto.getCategory() == null || dto.getCategory().isBlank()) ? "general" : dto.getCategory();
        BinReport report = new BinReport(userId, dto.getLatitude(), dto.getLongitude(),
                dto.getName(), category, dto.getAddress(), dto.getDescription());
        binReportRepository.save(report);

        return ResponseEntity.ok(new BinReportResponseDto(report));
    }

    // 내가 제출한 제보 목록 (마이페이지 '작성한 제보' 탭)
    @GetMapping("/api/reports/mine")
    @ResponseBody
    public ResponseEntity<?> myReports(HttpServletRequest request) {
        Long userId = currentUserId(request);
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("message", "로그인이 필요합니다."));
        }

        List<BinReportResponseDto> result = binReportRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(BinReportResponseDto::new)
                .toList();
        return ResponseEntity.ok(result);
    }

    private Long currentUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute(LoginController.SESSION_USER_ID) == null) {
            return null;
        }
        return (Long) session.getAttribute(LoginController.SESSION_USER_ID);
    }
}