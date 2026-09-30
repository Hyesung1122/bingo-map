package com.bingomap.bingo_map.common;

import com.bingomap.bingo_map.user.LoginController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * 리뷰 작성 시 업로드되는 이미지 파일(프로젝트 루트의 uploads/ 폴더)을
 * /uploads/** 경로로 정적 서빙하기 위한 설정.
 */
@Configuration
public class WebConfig implements WebMvcConfigurer {
//깃허브 풀 리퀘스트 테스트 0930
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(favoritesPageGuard())
                .addPathPatterns("/favorites/favorites.html");
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
