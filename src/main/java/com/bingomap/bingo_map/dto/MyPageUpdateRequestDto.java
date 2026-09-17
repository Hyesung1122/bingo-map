package com.bingomap.bingo_map.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.Setter;

/** PUT /api/mypage/me 요청용 DTO */
@Getter
@Setter
public class MyPageUpdateRequestDto {

    @NotBlank(message = "이름을 입력해주세요.")
    private String name;

    @NotBlank(message = "닉네임을 입력해주세요.")
    @Pattern(regexp = "^[가-힣a-zA-Z0-9]{2,12}$", message = "닉네임은 한글/영문/숫자 2~12자로 입력해주세요.")
    private String nickname;

    @Pattern(regexp = "^(대한민국|미국|일본)$", message = "국적은 대한민국/미국/일본 중에서 선택해주세요.")
    private String nationality;
}