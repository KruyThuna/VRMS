package com.vrms.controller;

import com.vrms.model.Vehicle;
import com.vrms.service.VehicleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/vehicles")
@CrossOrigin(origins = "*", allowedHeaders = "*")
@Tag(name = "1. Fleet & Vehicles", description = "Vehicle catalog, technical specifications, rental pricing, and stock availability")
public class VehicleController {

    private final VehicleService vehicleService;

    public VehicleController(VehicleService vehicleService) {
        this.vehicleService = vehicleService;
    }

    @Operation(summary = "List All Vehicles", description = "Retrieves all vehicles in the rental fleet.")
    @GetMapping
    public ResponseEntity<List<Vehicle>> getVehicles() {
        return ResponseEntity.ok(vehicleService.getAllVehicles());
    }

    @Operation(summary = "Get Vehicle by ID", description = "Retrieves details of a specific vehicle by its ID.")
    @GetMapping("/{id}")
    public ResponseEntity<Vehicle> getVehicleById(@PathVariable String id) {
        return ResponseEntity.ok(vehicleService.getVehicleById(id));
    }

    @Operation(summary = "Create Vehicle", description = "Adds a new vehicle to the rental catalog.")
    @PostMapping
    public ResponseEntity<Vehicle> createVehicle(@RequestBody Vehicle vehicle) {
        return ResponseEntity.ok(vehicleService.saveVehicle(vehicle));
    }

    @Operation(summary = "Update Vehicle", description = "Updates an existing vehicle by ID.")
    @PutMapping("/{id}")
    public ResponseEntity<Vehicle> updateVehicle(@PathVariable String id, @RequestBody Vehicle vehicle) {
        vehicle.setId(id);
        return ResponseEntity.ok(vehicleService.saveVehicle(vehicle));
    }

    @Operation(summary = "Delete Vehicle", description = "Deletes a vehicle from the fleet by ID.")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteVehicle(@PathVariable String id) {
        vehicleService.deleteVehicle(id);
        return ResponseEntity.noContent().build();
    }
}

