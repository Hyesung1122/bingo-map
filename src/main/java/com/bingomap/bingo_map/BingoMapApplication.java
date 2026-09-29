package com.bingomap.bingo_map;

import com.bingomap.bingo_map.map.WasteBinDbLoader;
import com.bingomap.bingo_map.restaurant.RestaurantDbLoader;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class BingoMapApplication {

	public static void main(String[] args) {

		try {
			System.out.println();
			System.out.println("========================================");
			System.out.println("BinGo Map 시작");
			System.out.println("========================================");

			// 1단계
			System.out.println();
			System.out.println("[1/2] 쓰레기통 데이터 적재를 시작합니다.");
			WasteBinDbLoader.load();

			// 2단계
			System.out.println();
			System.out.println("[2/2] 맛집 데이터 적재를 시작합니다.");
			RestaurantDbLoader.load();

			// 3단계
			System.out.println();
			System.out.println("========================================");
			System.out.println("데이터 적재 완료");
			System.out.println("Spring Boot 서버를 시작합니다.");
			System.out.println("========================================");

			SpringApplication.run(
					BingoMapApplication.class,
					args
			);

		} catch (Exception e) {

			System.err.println();
			System.err.println("========================================");
			System.err.println("BinGo Map 시작 실패");
			System.err.println("데이터 적재 과정에서 오류가 발생했습니다.");
			System.err.println("Spring Boot 서버는 시작하지 않습니다.");
			System.err.println("========================================");

			e.printStackTrace();

			System.exit(1);
		}
	}
}