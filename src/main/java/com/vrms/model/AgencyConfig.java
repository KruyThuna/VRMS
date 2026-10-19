package com.vrms.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "agency_config")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AgencyConfig {

    @Id
    @Builder.Default
    private String id = "default";

    @Builder.Default
    private String companyName = "DriveLine";

    @Builder.Default
    private String companySlogan = "CAR RENTAL";

    @Builder.Default
    private String phone = "+855 23 999 888";

    @Builder.Default
    private String email = "booking@driveline-rental.com";

    @Builder.Default
    private String address = "Phnom Penh & Siem Reap, Cambodia";

    private String logoUrl;
}

