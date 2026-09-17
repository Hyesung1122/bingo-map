package com.bingomap.bingo_map.dto;

import lombok.Getter;
import lombok.Setter;

/**
 * login.html의 <form action="/login" method="post"> 에서 넘어오는
 * email, password 필드를 그대로 받는 DTO.
 */
@Getter
@Setter
public class LoginRequestDto {
    private String email;
    private String password;
}
