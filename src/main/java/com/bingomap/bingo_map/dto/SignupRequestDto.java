package com.bingomap.bingo_map.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.Setter;

/**
 * signup.html의 <form action="/signup" method="post"> 에서 넘어오는
 * name, email, password, passwordConfirm, agreeTerms 필드를 그대로 받는 DTO.
 * 폼 전송(application/x-www-form-urlencoded)이라 @ModelAttribute로 바인딩한다.
 */
@Getter
@Setter
public class SignupRequestDto {

    @NotBlank(message = "이름을 입력해주세요.")
    private String name;

    @NotBlank(message = "닉네임을 입력해주세요.")
    @Pattern(regexp = "^[가-힣a-zA-Z0-9]{2,12}$", message = "닉네임은 한글/영문/숫자 2~12자로 입력해주세요.")
    private String nickname;

    @NotBlank(message = "이메일을 입력해주세요.")
    @Email(message = "올바른 이메일 형식이 아닙니다.")
    private String email;

    // 8자 이상, 영문/숫자/특수문자 각 1개 이상 포함
    @NotBlank(message = "비밀번호를 입력해주세요.")
    @Pattern(
            regexp = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$",
            message = "비밀번호는 영문, 숫자, 특수문자를 포함해 8자 이상이어야 합니다."
    )
    private String password;

    @NotBlank(message = "비밀번호 확인을 입력해주세요.")
    private String passwordConfirm;

    private String nationality;   // 선택 입력 (화면에는 아직 없음)
    private boolean agreeTerms;

    @NotBlank(message = "본인확인 질문을 선택해주세요.")
    private String securityQuestion;

    @NotBlank(message = "본인확인 답변을 입력해주세요.")
    private String securityAnswer;
}