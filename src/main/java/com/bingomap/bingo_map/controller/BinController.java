package com.bingomap.bingo_map.controller;

import com.bingomap.bingo_map.dto.WasteBinDto;
import com.bingomap.bingo_map.service.WasteBinService;
import org.springframework.dao.DataAccessException;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@RestController
@RequestMapping("/api/bins")
public class BinController
{
    private static final Logger LOG = Logger.getLogger(BinController.class.getName());
    private final WasteBinService wasteBinService;

    public BinController(WasteBinService wasteBinService) {
        this.wasteBinService = wasteBinService;
    }

    // 기본은 오사카(도톤보리). 나중에 도시가 늘어나면 /api/bins?city=tokyo 로 호출
    @GetMapping
    public ResponseEntity<?> getBins(@RequestParam(defaultValue = "osaka") String city) {
        try {
            List<WasteBinDto> bins = wasteBinService.getWasteBins(city);
            return ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(bins);
        } catch (DataAccessException e) {
            LOG.log(Level.WARNING, "WASTE_BIN 조회 실패: DB 연결, 테이블을 확인하세요.", e);
            return ResponseEntity.status(503).cacheControl(CacheControl.noStore())
                    .body("쓰레기통 DB를 조회하지 못했습니다. Oracle 연결·WASTE_BIN 테이블을 확인해주세요.");
        }
    }
}
