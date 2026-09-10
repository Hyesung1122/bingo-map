package com.bingomap.bingo_map.service;

import com.bingomap.bingo_map.dto.SignupRequestDto;
import com.bingomap.bingo_map.entity.User;
import com.bingomap.bingo_map.exception.SignupException;
import com.bingomap.bingo_map.repository.UserRepository;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class SignupService {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public SignupService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    /**
     * 회원가입 처리
     * 1) 약관 동의 확인
     * 2) 비밀번호 / 비밀번호 확인 일치 여부 확인
     * 3) 이메일 중복 확인
     * 4) 비밀번호 암호화 후 저장
     */
    public User signup(SignupRequestDto dto) {

        if (!dto.isAgreeTerms()) {
            throw new SignupException("이용약관에 동의해야 회원가입할 수 있습니다.");
        }

        if (dto.getPassword() == null || !dto.getPassword().equals(dto.getPasswordConfirm())) {
            throw new SignupException("비밀번호와 비밀번호 확인이 일치하지 않습니다.");
        }

        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new SignupException("이미 가입된 이메일입니다.");
        }

        String encodedPassword = passwordEncoder.encode(dto.getPassword());

        User user = new User(
                dto.getName(),
                dto.getEmail(),
                encodedPassword,
                dto.getNationality(),
                "NONE"
        );

        return userRepository.save(user);
    }
}