package com.bingomap.bingo_map.routing;

import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** 추가: 브라우저 → 이 Java 서버 → openrouteservice. 기존 /api/bins와 독립적입니다. */
@RestController
@RequestMapping("/api/routes")
public class RouteController {
    private final RouteService service;
    public RouteController(RouteService service) { this.service = service; }

    @PostMapping
    public ResponseEntity<RouteModels.Route> route(@RequestBody RouteModels.Request request) {
        return ResponseEntity.ok().header("Cache-Control", "no-store").body(service.route(request));
    }

    @ExceptionHandler(RouteModels.Failure.class)
    public ResponseEntity<RouteModels.Error> failure(RouteModels.Failure error) {
        return ResponseEntity.status(error.status).header("Cache-Control", "no-store")
                .body(new RouteModels.Error(error.code, error.getMessage()));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<RouteModels.Error> invalidJson() {
        return ResponseEntity.badRequest().body(new RouteModels.Error("INVALID_REQUEST", "요청 형식을 확인해주세요."));
    }
}
