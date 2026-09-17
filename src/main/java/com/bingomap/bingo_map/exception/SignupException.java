package com.bingomap.bingo_map.exception;

/** 회원가입 검증 실패(이메일 중복, 비밀번호 불일치, 약관 미동의 등) 시 던지는 예외 */
public class SignupException extends RuntimeException {
    public SignupException(String message) {
        super(message);
    }
}