package com.bingomap.bingo_map.service;

import com.bingomap.bingo_map.dto.LoginRequestDto;
import com.bingomap.bingo_map.entity.User;
import com.bingomap.bingo_map.exception.LoginException;
import com.bingomap.bingo_map.repository.UserRepository;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class LoginService {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public LoginService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    /**
     * 로그인 처리
     * 이메일로 회원을 찾고, 저장된 암호화 비밀번호와 입력한 비밀번호를 대조한다.
     * 보안상 "이메일이 없음"과 "비밀번호 틀림"을 구분하지 않고 같은 메시지로 응답한다.
     */
    public User login(LoginRequestDto dto) {
        User user = userRepository.findByEmail(dto.getEmail())
                .orElseThrow(() -> new LoginException("아이디 또는 비밀번호가 올바르지 않습니다. 입력한 정보를 다시 확인해 주세요."));

        if (user.getPassword() == null
                || !passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            throw new LoginException("아이디 또는 비밀번호가 올바르지 않습니다. 입력한 정보를 다시 확인해 주세요.");
        }

        return user;
    }
}