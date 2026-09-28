package com.bingomap.bingo_map;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing // BaseEntity의 @CreatedDate/@LastModifiedDate가 동작하려면 반드시 필요
public class BingoMapApplication {
	public static void main(String[] args) {
		SpringApplication.run(BingoMapApplication.class, args);
	}

}
