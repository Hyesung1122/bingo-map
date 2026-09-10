package com.bingomap.bingo_map.dto;

public class WasteBinDto {
    private Long id;
    private double lat;
    private double lon;
    private String name;
    private String category; // general / recycle / can
    private String address;

    public WasteBinDto(Long id, double lat, double lon, String name, String category, String address) {
        this.id = id;
        this.lat = lat;
        this.lon = lon;
        this.name = name;
        this.category = category;
        this.address = address;
    }

    public Long getId() { return id; }
    public double getLat() { return lat; }
    public double getLon() { return lon; }
    public String getName() { return name; }
    public String getCategory() { return category; }
    public String getAddress() { return address; }
}
