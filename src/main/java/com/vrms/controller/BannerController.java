package com.vrms.controller;

import com.vrms.model.BannerItem;
import com.vrms.service.BannerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/banners")
@CrossOrigin(origins = "*", allowedHeaders = "*")
@Tag(name = "4. Marketing Banners", description = "Showcase hero banners, promotional cards, and highlighted vehicles")
public class BannerController {

    private final BannerService bannerService;

    public BannerController(BannerService bannerService) {
        this.bannerService = bannerService;
    }

    @Operation(summary = "List All Banners", description = "Retrieves all showcase hero banners.")
    @GetMapping
    public ResponseEntity<List<BannerItem>> getBanners() {
        return ResponseEntity.ok(bannerService.getAllBanners());
    }

    @Operation(summary = "Get Banner by ID", description = "Retrieves a specific banner by its ID.")
    @GetMapping("/{id}")
    public ResponseEntity<BannerItem> getBannerById(@PathVariable String id) {
        return ResponseEntity.ok(bannerService.getBannerById(id));
    }

    @Operation(summary = "Create Banner", description = "Creates a new showcase hero banner.")
    @PostMapping
    public ResponseEntity<BannerItem> createBanner(@RequestBody BannerItem banner) {
        return ResponseEntity.ok(bannerService.saveBanner(banner));
    }

    @Operation(summary = "Update Banner", description = "Updates an existing banner by ID.")
    @PutMapping("/{id}")
    public ResponseEntity<BannerItem> updateBanner(@PathVariable String id, @RequestBody BannerItem banner) {
        banner.setId(id);
        return ResponseEntity.ok(bannerService.saveBanner(banner));
    }

    @Operation(summary = "Delete Banner", description = "Deletes a banner by ID.")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBanner(@PathVariable String id) {
        bannerService.deleteBanner(id);
        return ResponseEntity.noContent().build();
    }
}

