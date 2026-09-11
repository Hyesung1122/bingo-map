package com.bingomap.bingo_map.routing;

import org.springframework.stereotype.Service;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpTimeoutException;
import java.time.Duration;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import static com.bingomap.bingo_map.routing.RouteModels.*;

/**
 * 교체 버전: 회원가입/API 키 없이 FOSSGIS의 공개 OSRM 서버로 소규모 로컬 테스트.
 * 운영 서비스로 배포하기 전에는 별도 경로 서비스 계약 또는 직접 서버 운영을 준비하세요.
 * 정책: https://routing.openstreetmap.de/about.html
 */
@Service
public class RouteService {
    private final HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(8)).build();
    private final JsonMapper mapper = JsonMapper.builder().build();

    // 변경: ORS_API_KEY와 Authorization 헤더를 사용하지 않습니다.
    // 같은 실행 중인 Java 서버에서 모든 이동수단을 합쳐 요청 시작 간격 1.1초 이상 유지.
    private long nextRequestNanos = System.nanoTime();
    private long blockedUntilNanos = System.nanoTime();
    private record Cached(Route route, long createdNanos) {}
    private final Map<Request, Cached> cache = new LinkedHashMap<>(128, 0.75f, true);

    public Route route(Request input) {
        String server = validate(input);
        Route cached = cached(input);
        if (cached != null) return cached;
        try {
            awaitRequestSlot();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(requestUri(input, server))
                    .timeout(Duration.ofSeconds(20))
                    .header("User-Agent", "BinGoMapLearning/1.0 (local development routing test)")
                    .header("Accept", "application/json")
                    .GET().build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 429) {
                long seconds = 60;
                try { seconds = Math.max(60, Long.parseLong(response.headers().firstValue("Retry-After").orElse("60"))); }
                catch (NumberFormatException ignored) {}
                synchronized (this) { blockedUntilNanos = System.nanoTime() + TimeUnit.SECONDS.toNanos(Math.min(seconds, 86400)); }
                throw new Failure(429, "RATE_LIMIT", "공개 경로 서버의 요청 한도에 도달했습니다. 잠시 후 다시 시도해주세요.");
            }
            if (response.statusCode() != 200) throw upstreamFailure(response.body());
            Route result = parse(response.body(), input);
            synchronized (cache) {
                if (cache.size() >= 100) cache.remove(cache.keySet().iterator().next());
                cache.put(input, new Cached(result, System.nanoTime()));
            }
            return result;
        } catch (HttpTimeoutException e) {
            throw new Failure(504, "TIMEOUT", "공개 경로 서버의 응답 시간이 초과됐습니다. 잠시 후 다시 조회해주세요.");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new Failure(503, "INTERRUPTED", "경로 요청이 중단됐습니다. 다시 조회해주세요.");
        } catch (IOException e) {
            throw new Failure(502, "UPSTREAM_UNAVAILABLE", "공개 경로 서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.");
        }
    }

    private Route cached(Request request) {
        synchronized (cache) {
            Cached entry = cache.get(request);
            if (entry == null) return null;
            if (System.nanoTime() - entry.createdNanos() < TimeUnit.MINUTES.toNanos(5)) return entry.route();
            cache.remove(request);
            return null;
        }
    }

    private synchronized void awaitRequestSlot() throws InterruptedException {
        long deadline = System.nanoTime() + TimeUnit.SECONDS.toNanos(6);
        while (true) {
            long now = System.nanoTime();
            if (now < blockedUntilNanos) throw new Failure(429, "RATE_LIMIT", "공개 경로 서버의 요청 제한이 해제될 때까지 잠시 기다려주세요.");
            if (now >= nextRequestNanos) { nextRequestNanos = now + TimeUnit.MILLISECONDS.toNanos(1100); return; }
            if (now >= deadline) throw new Failure(429, "BUSY", "경로 요청이 많습니다. 잠시 후 다시 조회해주세요.");
            long remaining = Math.min(nextRequestNanos - now, deadline - now);
            TimeUnit.NANOSECONDS.timedWait(this, remaining);
        }
    }

    URI requestUri(Request r, String server) {
        // 변경: 각 이동수단에 맞춰 준비된 서로 다른 서버를 사용합니다.
        // /route/v1/driving의 문자열만 바꿔서는 이동수단이 바뀌지 않습니다.
        // routed-foot / routed-bike / routed-car가 실제 도로망을 선택합니다.
        return URI.create("https://routing.openstreetmap.de/" + server + "/route/v1/driving/"
                + r.startLon() + "," + r.startLat() + ";" + r.endLon() + "," + r.endLat()
                + "?overview=full&geometries=geojson&steps=true&radiuses=200;200&generate_hints=false");
    }

    static String validate(Request r) {
        if (r == null || !coordinate(r.startLat(), 90) || !coordinate(r.endLat(), 90)
                || !coordinate(r.startLon(), 180) || !coordinate(r.endLon(), 180)) {
            throw new Failure(400, "INVALID_COORDINATES", "출발지와 목적지 좌표를 확인해주세요.");
        }
        String server = switch (r.mode() == null ? "" : r.mode()) {
            case "walk" -> "routed-foot";
            case "bike" -> "routed-bike";
            case "car" -> "routed-car";
            default -> throw new Failure(400, "INVALID_MODE", "도보, 자전거, 자동차 중 하나를 선택해주세요.");
        };
        if (distance(r.startLat(), r.startLon(), r.endLat(), r.endLon()) > 50_000) {
            throw new Failure(422, "TOO_FAR", "목적지에서 50km 이내의 출발지를 사용해주세요. 한국에서 테스트한다면 도톤보리 테스트 출발점을 선택해주세요.");
        }
        return server;
    }

    private static boolean coordinate(Double value, int limit) {
        return value != null && Double.isFinite(value) && Math.abs(value) <= limit;
    }

    Failure upstreamFailure(String body) {
        String code = "";
        try { code = mapper.readTree(body).path("code").asText(""); }
        catch (RuntimeException ignored) {}
        if ("NoRoute".equals(code) || "NoSegment".equals(code)) {
            return new Failure(422, "NO_ROUTE", "이 이동수단으로 연결되는 경로를 찾지 못했습니다. 다른 이동수단을 선택해주세요.");
        }
        return new Failure(502, "ROUTING_FAILED", "공개 경로 서버가 요청을 처리하지 못했습니다. 잠시 후 다시 시도해주세요.");
    }

    Route parse(String json, Request input) {
        try {
            JsonNode root = mapper.readTree(json);
            if (!"Ok".equals(root.path("code").asText())) throw upstreamFailure(json);
            JsonNode routes = root.path("routes");
            if (!routes.isArray() || routes.isEmpty()) throw new IllegalArgumentException();
            JsonNode route = routes.get(0), legs = route.path("legs");
            // 이 앱은 출발/목적지 2개만 보내므로 leg가 1개여야 합니다.
            if (!legs.isArray() || legs.size() != 1) throw new IllegalArgumentException();
            List<List<Double>> coordinates = new ArrayList<>();
            List<Step> steps = new ArrayList<>();
            // 변경: OSRM의 단계별 geometry를 연결해 기존 화면이 쓰는 시작/끝 인덱스를 만듭니다.
            // 경로가 되돌아가 같은 좌표를 재방문해도 순서가 어긋나지 않습니다.
            for (JsonNode step : legs.get(0).path("steps")) {
                JsonNode geometry = step.path("geometry"), points = geometry.path("coordinates");
                if (!"LineString".equals(geometry.path("type").asText()) || !points.isArray() || points.size() < 2) throw new IllegalArgumentException();
                List<Double> first = point(points.get(0));
                if (coordinates.isEmpty()) coordinates.add(first);
                else if (!coordinates.get(coordinates.size() - 1).equals(first)) throw new IllegalArgumentException();
                int startIndex = coordinates.size() - 1;
                for (int i = 1; i < points.size(); i++) {
                    List<Double> next = point(points.get(i));
                    if (!coordinates.get(coordinates.size() - 1).equals(next)) coordinates.add(next);
                }
                JsonNode maneuver = step.path("maneuver");
                String kind = maneuver.path("type").asText("");
                String modifier = maneuver.path("modifier").asText("");
                int type = type(kind, modifier);
                String text = instruction(type);
                if (("roundabout".equals(kind) || "rotary".equals(kind)) && maneuver.path("exit").asInt(0) > 0) {
                    text = "회전교차로에서 " + maneuver.path("exit").asInt() + "번째 출구로 이동";
                } else if ("on ramp".equals(kind)) text = "진입로로 이동";
                else if ("off ramp".equals(kind)) text = "진출로로 이동";
                else if ("merge".equals(kind)) text = "합류 지점에서 " + text;
                steps.add(new Step(type, text, step.path("name").asText(""),
                        number(step, "distance"), number(step, "duration"), startIndex, coordinates.size() - 1));
            }
            if (steps.isEmpty() || coordinates.size() < 2) throw new IllegalArgumentException();
            List<Double> first = coordinates.get(0), last = coordinates.get(coordinates.size() - 1);
            return new Route(input.mode(), number(route, "distance"), number(route, "duration"),
                    List.copyOf(coordinates), List.copyOf(steps),
                    distance(input.startLat(), input.startLon(), first.get(1), first.get(0)),
                    distance(input.endLat(), input.endLon(), last.get(1), last.get(0)));
        } catch (Failure e) { throw e; }
        catch (RuntimeException e) { throw new Failure(502, "INVALID_RESPONSE", "경로 응답을 읽지 못했습니다. 잠시 후 다시 시도해주세요."); }
    }

    private static List<Double> point(JsonNode point) {
        if (!point.isArray() || point.size() < 2 || !point.get(0).isNumber() || !point.get(1).isNumber()) throw new IllegalArgumentException();
        double lon = point.get(0).asDouble(), lat = point.get(1).asDouble();
        if (!coordinate(lon, 180) || !coordinate(lat, 90)) throw new IllegalArgumentException();
        return List.of(lon, lat);
    }

    private static double number(JsonNode node, String key) {
        JsonNode value = node.path(key); double n = value.asDouble(Double.NaN);
        if (!value.isNumber() || !Double.isFinite(n) || n < 0) throw new IllegalArgumentException();
        return n;
    }

    private static int type(String kind, String modifier) {
        if ("depart".equals(kind)) return 11;
        if ("arrive".equals(kind)) return 10;
        if ("roundabout".equals(kind) || "rotary".equals(kind)) return 7;
        if ("exit roundabout".equals(kind) || "exit rotary".equals(kind)) return 8;
        if ("fork".equals(kind)) return modifier.contains("left") ? 12 : modifier.contains("right") ? 13 : 6;
        return switch (modifier) {
            case "left" -> 0; case "right" -> 1; case "sharp left" -> 2; case "sharp right" -> 3;
            case "slight left" -> 4; case "slight right" -> 5; case "uturn" -> 9; default -> 6;
        };
    }

    private static String instruction(int type) {
        return switch (type) {
            case 0 -> "왼쪽으로 이동"; case 1 -> "오른쪽으로 이동";
            case 2 -> "크게 왼쪽으로 이동"; case 3 -> "크게 오른쪽으로 이동";
            case 4 -> "완만하게 왼쪽으로 이동"; case 5 -> "완만하게 오른쪽으로 이동";
            case 6 -> "직진"; case 7 -> "회전교차로 진입"; case 8 -> "회전교차로에서 나가기";
            case 9 -> "방향을 돌려 이동"; case 10 -> "경로 끝에 도착"; case 11 -> "출발";
            case 12 -> "왼쪽 길 유지"; case 13 -> "오른쪽 길 유지"; default -> "경로를 따라 이동";
        };
    }

    static double distance(double lat1, double lon1, double lat2, double lon2) {
        double a = Math.pow(Math.sin(Math.toRadians(lat2 - lat1) / 2), 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.pow(Math.sin(Math.toRadians(lon2 - lon1) / 2), 2);
        return 6_371_000 * 2 * Math.asin(Math.sqrt(Math.min(1, Math.max(0, a))));
    }
}
