package com.vrms.model;

import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "banners")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BannerItem {

    @Id
    private String id;

    private String tagline;
    private String title;
    private String subtitle;
    private String vehicleId;

    @Column(length = 2048)
    private String imageUrl;

    private String priceText;

    @ElementCollection
    @Builder.Default
    private List<String> specChips = new ArrayList<>();

    private String badgeText;
    private long badgeColorValue;
    private boolean active;
}

