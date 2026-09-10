package com.bingomap.bingo_map.controller;

import com.bingomap.bingo_map.dto.WasteBinDto;
import com.bingomap.bingo_map.service.WasteBinService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/bins")
public class BinController
{
    private final WasteBinService wasteBinService;

    public BinController(WasteBinService wasteBinService) {
        this.wasteBinService = wasteBinService;
    }

    @GetMapping
    public List<WasteBinDto> getBins() {
        return wasteBinService.getWasteBins();
    }
}
