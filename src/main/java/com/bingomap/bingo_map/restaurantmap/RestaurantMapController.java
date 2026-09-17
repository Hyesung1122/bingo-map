package com.bingomap.bingo_map.restaurantmap;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataAccessException;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import static com.bingomap.bingo_map.restaurantmap.RestaurantMapModels.*;

@RestController
@RequestMapping("/api/map/restaurants")
public class RestaurantMapController {
    private static final Logger LOG = Logger.getLogger(RestaurantMapController.class.getName());
    private final RestaurantMapRepository repository;
    private final boolean sampleData;

    public RestaurantMapController(RestaurantMapRepository repository,
            @Value("${bingo.restaurant-map.sample-data:true}") boolean sampleData) {
        this.repository = repository;
        this.sampleData = sampleData;
    }

    @GetMapping
    public ResponseEntity<?> list() {
        try {
            List<Place> all = repository.findAll();
            List<Place> valid = all.stream().filter(RestaurantMapRepository::hasCoordinates).toList();
            int skipped = all.size() - valid.size();
            String message = skipped == 0 ? "" : "좌표가 없거나 올바르지 않은 식당 " + skipped + "곳은 지도 표시에서 제외했습니다.";
            Result result = new Result(valid, all.size(), skipped, sampleData, Instant.now(),
                    "ORACLE_RESTAURANT", message);
            return ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(result);
        } catch (DataAccessException e) {
            LOG.log(Level.WARNING, "RESTAURANT 조회 실패: DB 연결, 스키마, 테이블 컬럼을 확인하세요.", e);
            return ResponseEntity.status(503).cacheControl(CacheControl.noStore())
                    .body(new RestaurantMapModels.Error("식당 DB를 조회하지 못했습니다. Oracle 연결·RESTAURANT 테이블과 서버 로그를 확인해주세요."));
        }
    }
}
