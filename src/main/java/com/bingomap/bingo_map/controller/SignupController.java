package com.bingomap.bingo_map.controller;

import com.bingomap.bingo_map.dto.SignupRequestDto;
import com.bingomap.bingo_map.exception.SignupException;
import com.bingomap.bingo_map.service.SignupService;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
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
    public String signup(@Valid @ModelAttribute SignupRequestDto requestDto, BindingResult bindingResult) {

        // 유효성 검증 실패 (이메일 형식, 비밀번호 강도 등) -> 첫 번째 에러 메시지만 보여줌
        if (bindingResult.hasErrors()) {
            FieldError firstError = bindingResult.getFieldErrors().get(0);
            return redirectWithError(firstError.getDefaultMessage());
        }

        try {
            signupService.signup(requestDto);
            // 가입 성공 -> 로그인 페이지로 이동
            return "redirect:/login?signup=success";
        } catch (SignupException e) {
            // 가입 실패(중복 이메일, 비밀번호 불일치 등) -> 에러 메시지와 함께 회원가입 페이지로 되돌아감
            return redirectWithError(e.getMessage());
        }
    }

    private String redirectWithError(String message) {
        String encoded = URLEncoder.encode(message, StandardCharsets.UTF_8);
        return "redirect:/signup?error=" + encoded;
    }
}