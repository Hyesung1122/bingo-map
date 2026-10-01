package com.bingomap.bingo_map.common;

import com.bingomap.bingo_map.user.LoginController;
import com.bingomap.bingo_map.user.User;
import com.bingomap.bingo_map.user.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;

/**
 * 리뷰 작성 시 업로드되는 이미지 파일(프로젝트 루트의 uploads/ 폴더)을
 * /uploads/** 경로로 정적 서빙하기 위한 설정.
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {
//깃허브 풀 리퀘스트 테스트 0930
    private final UserRepository userRepository;

    public WebConfig(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(favoritesPageGuard())
                .addPathPatterns("/favorites/favorites.html");
        registry.addInterceptor(blockedUserGuard())
                .addPathPatterns("/**")
                .excludePathPatterns(
                        "/login", "/logout", "/api/settings/public",
                        "/css/**", "/js/**", "/images/**", "/uploads/**",
                        "/**/*.css", "/**/*.js", "/**/*.png", "/**/*.jpg", "/**/*.jpeg",
                        "/**/*.gif", "/**/*.svg", "/**/*.ico", "/**/*.woff", "/**/*.woff2"
                );
    }

    private HandlerInterceptor blockedUserGuard() {
        return new HandlerInterceptor() {
            @Override
            public boolean preHandle(
                    HttpServletRequest request,
                    HttpServletResponse response,
                    Object handler
            ) throws Exception {
                HttpSession session = request.getSession(false);
                if (session == null) {
                    return true;
                }

                Object sessionId = session.getAttribute(LoginController.SESSION_USER_ID);
                if (!(sessionId instanceof Number)) {
                    return true;
                }

                Long userId = ((Number) sessionId).longValue();
                User user = userRepository.findById(userId).orElse(null);
                if (user != null && !user.isCurrentlyBlocked(LocalDateTime.now())) {
                    session.setAttribute(LoginController.SESSION_USER_ROLE, user.getRole());
                    return true;
                }

                session.invalidate();
                String message = user == null
                        ? "로그인 정보가 유효하지 않습니다. 다시 로그인해 주세요."
                        : user.isBlockedPermanently()
                                ? "관리자에 의해 영구 차단된 계정입니다."
                                : "관리자에 의해 일시 차단된 계정입니다.";
                response.sendRedirect(request.getContextPath() + "/login?error="
                        + URLEncoder.encode(message, StandardCharsets.UTF_8));
                return false;
            }
        };
    }

    private HandlerInterceptor favoritesPageGuard() {
        return new HandlerInterceptor() {
            @Override
            public boolean preHandle(
                    HttpServletRequest request,
                    HttpServletResponse response,
                    Object handler
            ) throws Exception {
                HttpSession session = request.getSession(false);
                if (session != null
                        && session.getAttribute(LoginController.SESSION_USER_ID) != null) {
                    return true;
                }

                response.sendRedirect(request.getContextPath()
                        + "/login?returnUrl=%2Ffavorites");
                return false;
            }
        };
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:uploads/");
    }
}
