package com.bingomap.bingo_map.exception;

/** 로그인 실패(이메일 없음, 비밀번호 불일치) 시 던지는 예외 */
public class LoginException extends RuntimeException {
    public LoginException(String message) {
        super(message);
    }
}