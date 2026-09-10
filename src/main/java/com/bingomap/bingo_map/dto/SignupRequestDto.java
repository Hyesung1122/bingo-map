package com.bingomap.bingo_map.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SignupRequestDto {
    private String name;
    private String email;
    private String password;
    private String passwordConfirm;
    private String nationality;
    private boolean agreeTerms;
}