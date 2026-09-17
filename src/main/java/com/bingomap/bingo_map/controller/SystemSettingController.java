package com.bingomap.bingo_map.controller;

import com.bingomap.bingo_map.dto.SettingsResponseDto;
import com.bingomap.bingo_map.dto.SettingsUpdateDto;
import com.bingomap.bingo_map.entity.SystemSetting;
import com.bingomap.bingo_map.repository.SystemSettingRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Map;

@Controller
public class SystemSettingController {

    private static final Long SETTING_ID = 1L;

    private final SystemSettingRepository settingRepository;

    public SystemSettingController(SystemSettingRepository settingRepository) {
        this.settingRepository = settingRepository;
    }

    // 공개 API: 헤더/회원가입 페이지 등에서 점검 배너, 가입 가능 여부 확인용
    @GetMapping("/api/settings/public")
    @ResponseBody
    public SettingsResponseDto publicSettings() {
        SystemSetting setting = getOrDefault();
        return toDto(setting);
    }

    // 관리자 설정 조회
    @GetMapping("/api/admin/settings")
    @ResponseBody
    public ResponseEntity<?> adminSettings(HttpServletRequest request) {
        if (!isAdmin(request)) {
            return ResponseEntity.status(403).body(Map.of("message", "관리자만 접근할 수 있습니다."));
        }
        return ResponseEntity.ok(toDto(getOrDefault()));
    }

    // 관리자 설정 변경
    @PutMapping("/api/admin/settings")
    @ResponseBody
    public ResponseEntity<?> updateSettings(@RequestBody SettingsUpdateDto dto, HttpServletRequest request) {
        if (!isAdmin(request)) {
            return ResponseEntity.status(403).body(Map.of("message", "관리자만 접근할 수 있습니다."));
        }

        SystemSetting setting = getOrDefault();
        setting.setSignupEnabled(dto.isSignupEnabled() ? "Y" : "N");
        setting.setMaintenanceMode(dto.isMaintenanceMode() ? "Y" : "N");
        setting.setMaintenanceMessage(dto.getMaintenanceMessage());
        settingRepository.save(setting);

        return ResponseEntity.ok(toDto(setting));
    }

    // 다른 곳(SignupService 등)에서도 재사용하기 위한 헬퍼
    public SystemSetting getOrDefault() {
        return settingRepository.findById(SETTING_ID).orElseGet(() -> {
            SystemSetting fallback = new SystemSetting();
            fallback.setSettingId(SETTING_ID);
            fallback.setSignupEnabled("Y");
            fallback.setMaintenanceMode("N");
            return fallback;
        });
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && "ADMIN".equals(session.getAttribute(LoginController.SESSION_USER_ROLE));
    }

    private SettingsResponseDto toDto(SystemSetting s) {
        return new SettingsResponseDto(s.isSignupEnabled(), s.isMaintenanceMode(), s.getMaintenanceMessage());
    }
}