package com.vrms.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "vehicles")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Vehicle {

    @Id
    private String id;
    private String name;
    private String brand;
    private String type;
    private int dailyCents;
    private int purchasePrice;
    private boolean available;
    private String fuel;
    private int seats;
    private String transmission;
    private String engine;
    private String horsepower;
    private String topSpeed;
    private String acceleration;

    @Column(length = 2048)
    private String imageUrl;

    private boolean maintenance;
    private String tagline;

    @Column(name = "\"year\"")
    private int year;

    private String plate;

    public int getRate() {
        return dailyCents;
    }

    public void setRate(Integer rate) {
        if (rate != null && rate > 0) {
            this.dailyCents = rate;
        }
    }
}

