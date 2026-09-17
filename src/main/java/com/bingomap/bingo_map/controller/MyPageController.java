package com.bingomap.bingo_map.controller;

import com.bingomap.bingo_map.dto.MyPageResponseDto;
import com.bingomap.bingo_map.dto.MyPageUpdateRequestDto;
import com.bingomap.bingo_map.entity.User;
import com.bingomap.bingo_map.repository.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.format.DateTimeFormatter;
import java.util.Map;

@Controller
public class MyPageController {

    private static final DateTimeFormatter JOINED_FORMAT = DateTimeFormatter.ofPattern("yyyy.MM.dd");

    private final UserRepository userRepository;

    public MyPageController(UserRepository userRepository) {
        this.userRepository = userRepository;
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