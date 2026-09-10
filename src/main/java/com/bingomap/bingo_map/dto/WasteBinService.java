package com.bingomap.bingo_map.service;

import com.bingomap.bingo_map.dto.WasteBinDto;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;

@Service
public class WasteBinService {

    private static final String OVERPASS_URL = "https://overpass-api.de/api/interpreter";

    // 도톤보리 주변 bounding box (남, 서, 북, 동)
    private static final String BBOX = "34.664,135.495,34.674,135.508";

    public List<WasteBinDto> getWasteBins() {

        // waste_basket(일반)과 recycling(재활용/캔·병)을 함께 조회
        String query = """
            [out:json][timeout:25];
            (
              node["amenity"="waste_basket"](%s);
              node["amenity"="recycling"](%s);
            );
            out body;
            """.formatted(BBOX, BBOX);

        RestTemplate restTemplate = new RestTemplate();
        String response = restTemplate.postForObject(
                OVERPASS_URL,
                "data=" + query,
                String.class
        );

        return parseResponse(response);
    }

    private List<WasteBinDto> parseResponse(String json) {
        List<WasteBinDto> bins = new ArrayList<>();
        try {
            JsonMapper mapper = JsonMapper.builder().build();
            JsonNode root = mapper.readTree(json);
            JsonNode elements = root.get("elements");

            for (JsonNode el : elements) {
                Long id = el.get("id").asLong();
                double lat = el.get("lat").asDouble();
                double lon = el.get("lon").asDouble();

                JsonNode tags = el.get("tags");

                String amenity = tags != null && tags.has("amenity")
                        ? tags.get("amenity").asText()
                        : "waste_basket";

                String name = "쓰레기통";
                if (tags != null && tags.has("name")) {
                    name = tags.get("name").asText();
                }

                String category = classifyCategory(amenity, tags);

                if (name.equals("쓰레기통") && !category.equals("general")) {
                    name = categoryLabel(category);
                }

                String address = extractAddress(tags);

                bins.add(new WasteBinDto(id, lat, lon, name, category, address));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bins;
    }

    /**
     * amenity=waste_basket        → general (일반쓰레기)
     * amenity=recycling + cans    → can (캔/병)
     * amenity=recycling (그 외)   → recycle (재활용)
     */
    private String classifyCategory(String amenity, JsonNode tags) {

        if (!"recycling".equals(amenity)) {
            return "general";
        }

        if (tags != null) {
            boolean cans = "yes".equals(textOrNull(tags, "recycling:cans"));
            boolean glass = "yes".equals(textOrNull(tags, "recycling:glass_bottles"));

            if (cans || glass) {
                return "can";
            }
        }

        return "recycle";
    }

    private String categoryLabel(String category) {
        return switch (category) {
            case "can" -> "캔/병 수거함";
            case "recycle" -> "재활용 수거함";
            default -> "쓰레기통";
        };
    }

    private String extractAddress(JsonNode tags) {
        if (tags == null) {
            return "주소 정보 없음";
        }

        String street = textOrNull(tags, "addr:street");
        String houseNumber = textOrNull(tags, "addr:housenumber");

        if (street != null) {
            return houseNumber != null ? street + " " + houseNumber : street;
        }

        return "주소 정보 없음";
    }

    private String textOrNull(JsonNode tags, String key) {
        return tags.has(key) ? tags.get(key).asText() : null;
    }
}
