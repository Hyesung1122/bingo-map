package com.bingomap.bingo_map.controller;

import com.bingomap.bingo_map.dto.SessionResponseDto;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 헤더 등 프론트엔드에서 "지금 로그인 상태인지"를 물어볼 때 쓰는 API.
 * 화면이 전부 정적 HTML이라 서버가 직접 HTML을 못 바꿔주는 대신,
 * 이 API 응답을 보고 JS(header-auth.js)가 화면을 바꾼다.
 */
@RestController
public class SessionController {

    @GetMapping("/api/session")
    public SessionResponseDto getSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute(LoginController.SESSION_USER_ID) == null) {
            return new SessionResponseDto(false, null, null);
        }

        String name = (String) session.getAttribute(LoginController.SESSION_USER_NAME);
        String role = (String) session.getAttribute(LoginController.SESSION_USER_ROLE);
        return new SessionResponseDto(true, name, role);
    }
}