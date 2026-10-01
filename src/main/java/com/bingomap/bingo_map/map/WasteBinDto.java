package com.bingomap.bingo_map.map;

public class WasteBinDto {

    private Long id;
    private Long osmId;
    private double lat;
    private double lon;
    private String name;
    private String category;
    private String address;

    public WasteBinDto(
            Long id,
            Long osmId,
            double lat,
            double lon,
            String name,
            String category,
            String address
    ) {
        this.id = id;
        this.osmId = osmId;
        this.lat = lat;
        this.lon = lon;
        this.name = name;
        this.category = category;
        this.address = address;
    }

    public Long getId() {
        return id;
    }

    public Long getOsmId() {
        return osmId;
    }

    public double getLat() {
        return lat;
    }

    public double getLon() {
        return lon;
    }

    public String getName() {
        String type = category == null ? "" : category.trim();

        if ("recycle".equalsIgnoreCase(type)) {
            return "재활용 수거함";
        }

        if ("can".equalsIgnoreCase(type)) {
            return "캔/병 수거함";
        }

        return "쓰레기통";
    }

    public String getCategory() {
        return category;
    }

    public String getAddress() {
        return address;
    }
}