package com.bingomap.bingo_map.service;

import com.bingomap.bingo_map.dto.SignupRequestDto;
import com.bingomap.bingo_map.entity.SystemSetting;
import com.bingomap.bingo_map.entity.User;
import com.bingomap.bingo_map.exception.SignupException;
import com.bingomap.bingo_map.repository.SystemSettingRepository;
import com.bingomap.bingo_map.repository.UserRepository;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class SignupService {

    private final UserRepository userRepository;
    private final SystemSettingRepository settingRepository;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public SignupService(UserRepository userRepository, SystemSettingRepository settingRepository) {
        this.userRepository = userRepository;
        this.settingRepository = settingRepository;
    }

    /**
     * 회원가입 처리
     * 0) 관리자가 회원가입을 막아놨는지 확인
     * 1) 약관 동의 확인
     * 2) 비밀번호 / 비밀번호 확인 일치 여부 확인
     * 3) 이메일 중복 확인
     * 4) 닉네임 중복 확인
     * 5) 비밀번호 암호화 후 저장
     */
    public User signup(SignupRequestDto dto) {

        SystemSetting setting = settingRepository.findById(1L).orElse(null);
        if (setting != null && !setting.isSignupEnabled()) {
            throw new SignupException("현재 회원가입이 일시 중단되었습니다. 잠시 후 다시 시도해주세요.");
        }

        if (!dto.isAgreeTerms()) {
            throw new SignupException("이용약관에 동의해야 회원가입할 수 있습니다.");
        }

        if (dto.getPassword() == null || !dto.getPassword().equals(dto.getPasswordConfirm())) {
            throw new SignupException("비밀번호와 비밀번호 확인이 일치하지 않습니다.");
        }

        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new SignupException("이미 가입된 이메일입니다.");
        }

        if (userRepository.existsByNickname(dto.getNickname())) {
            throw new SignupException("이미 사용 중인 닉네임입니다.");
        }

        String encodedPassword = passwordEncoder.encode(dto.getPassword());

        User user = new User(
                dto.getName(),
                dto.getNickname(),
                dto.getEmail(),
                encodedPassword,
                dto.getNationality(),
                "NONE"
        );

        // 답변은 대소문자/앞뒤공백 차이로 재설정할 때 틀리는 일이 없게 정규화 후 해시로 저장
        user.setSecurityQuestion(dto.getSecurityQuestion());
        user.setSecurityAnswer(passwordEncoder.encode(normalizeAnswer(dto.getSecurityAnswer())));

        return userRepository.save(user);
    }

    private String normalizeAnswer(String answer) {
        return answer.trim().toLowerCase().replaceAll("\\s+", "");
    }
}