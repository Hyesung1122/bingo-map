package com.bingomap.bingo_map.favorite;

import com.bingomap.bingo_map.user.LoginController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class FavoriteController
{
    @GetMapping("/favorites")
    public String favorites(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null
                || session.getAttribute(LoginController.SESSION_USER_ID) == null) {
            return "redirect:/login?returnUrl=%2Ffavorites";
        }
        return "forward:/favorites/favorites.html";
    }
}
