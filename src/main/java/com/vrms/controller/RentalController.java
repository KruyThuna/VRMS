package com.vrms.controller;

import com.vrms.model.Rental;
import com.vrms.service.RentalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rentals")
@CrossOrigin(origins = "*", allowedHeaders = "*")
@Tag(name = "2. Bookings & Rentals", description = "Customer rental reservations, contracts, returns, and payment management")
public class RentalController {

    private final RentalService rentalService;

    public RentalController(RentalService rentalService) {
        this.rentalService = rentalService;
    }

    @Operation(summary = "List All Rentals", description = "Retrieves all rental bookings and payment records.")
    @GetMapping
    public ResponseEntity<List<Rental>> getRentals() {
        return ResponseEntity.ok(rentalService.getAllRentals());
    }

    @Operation(summary = "Get Rental by ID", description = "Retrieves a specific booking by its ID.")
    @GetMapping("/{id}")
    public ResponseEntity<Rental> getRentalById(@PathVariable String id) {
        return ResponseEntity.ok(rentalService.getRentalById(id));
    }

    @Operation(summary = "Create Rental Booking", description = "Creates a new rental reservation contract.")
    @PostMapping
    public ResponseEntity<Rental> createRental(@RequestBody Rental rental) {
        return ResponseEntity.ok(rentalService.saveRental(rental));
    }

    @Operation(summary = "Update Rental Booking", description = "Updates an existing rental booking by ID.")
    @PutMapping("/{id}")
    public ResponseEntity<Rental> updateRental(@PathVariable String id, @RequestBody Rental rental) {
        rental.setId(id);
        return ResponseEntity.ok(rentalService.saveRental(rental));
    }

    @Operation(summary = "Delete Rental Booking", description = "Deletes a rental booking record by ID.")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRental(@PathVariable String id) {
        rentalService.deleteRental(id);
        return ResponseEntity.noContent().build();
    }
}

