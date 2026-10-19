package com.vrms.controller;

import com.vrms.model.AgencyConfig;
import com.vrms.service.AgencyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/agency")
@CrossOrigin(origins = "*", allowedHeaders = "*")
@Tag(name = "5. Agency Profile", description = "Agency corporate branding, contact numbers, address, and headquarters profile")
public class AgencyController {

    private final AgencyService agencyService;

    public AgencyController(AgencyService agencyService) {
        this.agencyService = agencyService;
    }

    @Operation(summary = "Get Agency Profile", description = "Retrieves agency corporate profile and branding settings.")
    @GetMapping
    public ResponseEntity<AgencyConfig> getAgencyConfig() {
        return ResponseEntity.ok(agencyService.getAgencyConfig());
    }

    @Operation(summary = "Update Agency Profile", description = "Updates agency corporate details.")
    @PutMapping
    public ResponseEntity<AgencyConfig> updateAgencyConfig(@RequestBody AgencyConfig config) {
        return ResponseEntity.ok(agencyService.updateAgencyConfig(config));
    }
}

