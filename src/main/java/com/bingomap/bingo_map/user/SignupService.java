package com.bingomap.bingo_map.user;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class SignupService {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder =
            new BCryptPasswordEncoder();

    public SignupService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    /**
     * 회원가입 처리
     * 1) 약관 동의 확인
     * 2) 비밀번호 / 비밀번호 확인 일치 여부 확인
     * 3) 이메일 중복 확인
     * 4) 닉네임 중복 확인
     * 5) 비밀번호 암호화 후 저장
     */
    public User signup(SignupRequestDto dto) {

        if (!dto.isAgreeTerms()) {
            throw new SignupException(
                    "이용약관에 동의해야 회원가입할 수 있습니다."
            );
        }

        if (dto.getPassword() == null
                || !dto.getPassword().equals(dto.getPasswordConfirm())) {
            throw new SignupException(
                    "비밀번호와 비밀번호 확인이 일치하지 않습니다."
            );
        }

        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new SignupException(
                    "이미 가입된 이메일입니다."
            );
        }

        if (userRepository.existsByNickname(dto.getNickname())) {
            throw new SignupException(
                    "이미 사용 중인 닉네임입니다."
            );
        }

        String encodedPassword =
                passwordEncoder.encode(dto.getPassword());

        User user = new User(
                dto.getName(),
                dto.getNickname(),
                dto.getEmail(),
                encodedPassword,
                dto.getNationality(),
                "NONE"
        );

        // 본인확인 질문/답변은 선택 항목: 둘 다 입력된 경우에만 저장 (비밀번호 찾기에 사용)
        if (dto.getSecurityQuestion() != null && !dto.getSecurityQuestion().isBlank()
                && dto.getSecurityAnswer() != null && !dto.getSecurityAnswer().isBlank()) {
            user.setSecurityQuestion(
                    dto.getSecurityQuestion()
            );

            user.setSecurityAnswer(
                    passwordEncoder.encode(
                            normalizeAnswer(dto.getSecurityAnswer())
                    )
            );
        }

        return userRepository.save(user);
    }

    private String normalizeAnswer(String answer) {
        return answer
                .trim()
                .toLowerCase()
                .replaceAll("\\s+", "");
    }
}