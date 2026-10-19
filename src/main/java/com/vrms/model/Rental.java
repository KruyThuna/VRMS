package com.vrms.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Entity
@Table(name = "rentals")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Rental {

    @Id
    private String id;

    private String vehicleId;
    private String customerId;
    private LocalDate startDate;
    private LocalDate endDate;
    private int dailyCents;
    private int paidCents;
    private boolean returned;
    private String status;
    private String notes;
}

