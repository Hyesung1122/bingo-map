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

		System.out.println();
		System.out.println("========================================");
		System.out.println("BinGo Map 시작");
		System.out.println("========================================");

		/*
		 * 1. 외부 데이터 적재
		 *
		 * 실제 DB/Overpass 적재 오류만 여기서 처리한다.
		 */
		try {

			System.out.println();
			System.out.println("[1/2] 쓰레기통 데이터 적재를 시작합니다.");

			WasteBinDbLoader.load();

			System.out.println();
			System.out.println("[2/2] 맛집 데이터 적재를 시작합니다.");

			RestaurantDbLoader.load();

		} catch (Exception e) {

			System.err.println();
			System.err.println("========================================");
			System.err.println("BinGo Map 시작 실패");
			System.err.println("데이터 적재 과정에서 오류가 발생했습니다.");
			System.err.println("Spring Boot 서버는 시작하지 않습니다.");
			System.err.println("========================================");

			e.printStackTrace();

			System.exit(1);
			return;
		}

		/*
		 * 중요:
		 * SpringApplication.run()은 위의 try-catch 밖에 둔다.
		 *
		 * Spring Boot DevTools는 재시작 과정에서
		 * SilentExitException을 발생시킬 수 있다.
		 * 이것을 데이터 적재 실패로 처리하면 안 된다.
		 */
		System.out.println();
		System.out.println("========================================");
		System.out.println("데이터 적재 완료");
		System.out.println("Spring Boot 서버를 시작합니다.");
		System.out.println("========================================");

		SpringApplication.run(
				BingoMapApplication.class,
				args
		);
	}
}