package com.bingomap.bingo_map.controller;

import com.bingomap.bingo_map.dto.SignupRequestDto;
import com.bingomap.bingo_map.exception.SignupException;
import com.bingomap.bingo_map.service.SignupService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Controller
public class SignupController
{
    private final SignupService signupService;

    public SignupController(SignupService signupService) {
        this.signupService = signupService;
    }

    @GetMapping("/signup")
    public String signup() {
        return "forward:/signup/signup.html";
    }

    @PostMapping("/signup")
    public String signup(@ModelAttribute SignupRequestDto requestDto) {
        try {
            signupService.signup(requestDto);
            // 가입 성공 -> 로그인 페이지로 이동
            return "redirect:/login?signup=success";
        } catch (SignupException e) {
            // 가입 실패 -> 에러 메시지와 함께 회원가입 페이지로 되돌아감
            String message = URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8);
            return "redirect:/signup?error=" + message;
        }
    }
}