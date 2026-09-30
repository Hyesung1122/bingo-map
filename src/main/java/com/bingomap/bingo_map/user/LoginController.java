package com.bingomap.bingo_map.user;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Controller
public class LoginController
{
    // 세션에 로그인 정보를 저장할 때 쓰는 key
    public static final String SESSION_USER_ID = "LOGIN_USER_ID";
    public static final String SESSION_USER_NAME = "LOGIN_USER_NAME";
    public static final String SESSION_USER_ROLE = "LOGIN_USER_ROLE";

    private final LoginService loginService;

    public LoginController(LoginService loginService) {
        this.loginService = loginService;
    }

    @GetMapping("/login")
    public String login() {
        return "forward:/login/login.html";
    }

    @PostMapping("/login")
    public String login(@ModelAttribute LoginRequestDto requestDto,
                        HttpServletRequest request,
                        @RequestParam(value = "returnUrl", required = false) String returnUrl) {
        String safeReturnUrl = safeReturnUrl(returnUrl);
        try {
            User user = loginService.login(requestDto);

            // 로그인 성공 -> 세션에 사용자 정보 저장
            HttpSession session = request.getSession();
            session.setAttribute(SESSION_USER_ID, user.getUserId());
            session.setAttribute(SESSION_USER_NAME, user.getName());
            session.setAttribute(SESSION_USER_ROLE, user.getRole());

            return "redirect:" + safeReturnUrl;
        } catch (LoginException e) {
            String message = URLEncoder.encode(e.getMessage(), StandardCharsets.UTF_8);
            return "redirect:/login?error=" + message
                    + "&returnUrl="
                    + URLEncoder.encode(safeReturnUrl, StandardCharsets.UTF_8);
        }
    }

    private String safeReturnUrl(String returnUrl) {
        if (returnUrl == null
                || !returnUrl.startsWith("/")
                || returnUrl.startsWith("//")
                || returnUrl.contains("\\")
                || returnUrl.contains("\r")
                || returnUrl.contains("\n")) {
            return "/";
        }
        return returnUrl;
    }

    @GetMapping("/logout")
    public String logout(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        return "redirect:/";
    }
}
