package com.vrms.controller;

import com.vrms.service.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*", allowedHeaders = "*")
@Tag(name = "0. System & Sync", description = "System health monitoring and client full-data synchronization")
public class SystemController {

    private final VehicleService vehicleService;
    private final BannerService bannerService;
    private final CustomerService customerService;
    private final RentalService rentalService;
    private final AgencyService agencyService;

    public SystemController(
            VehicleService vehicleService,
            BannerService bannerService,
            CustomerService customerService,
            RentalService rentalService,
            AgencyService agencyService) {
        this.vehicleService = vehicleService;
        this.bannerService = bannerService;
        this.customerService = customerService;
        this.rentalService = rentalService;
        this.agencyService = agencyService;
    }

    @Operation(summary = "System Health Check", description = "Returns system uptime, current server timestamp, and count of active fleet vehicles and banners.")
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> resp = new LinkedHashMap<>();
        resp.put("status", "UP");
        resp.put("app", "DriveLine VRMS Backend");
        resp.put("service", "Vehicle Rental Management System");
        resp.put("timestamp", LocalDateTime.now().toString());
        resp.put("vehiclesCount", vehicleService.count());
        resp.put("activeBannersCount", bannerService.count());
        return ResponseEntity.ok(resp);
    }

    @Operation(summary = "Full Data Sync", description = "Provides a complete snapshot of vehicles, banners, customers, rentals, and agency configuration in a single round-trip.")
    @GetMapping("/sync")
    public ResponseEntity<Map<String, Object>> syncAll() {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("vehicles", vehicleService.getAllVehicles());
        data.put("banners", bannerService.getAllBanners());
        data.put("customers", customerService.getAllCustomers());
        data.put("rentals", rentalService.getAllRentals());
        data.put("agencyConfig", agencyService.getAgencyConfig());
        return ResponseEntity.ok(data);
    }
}

