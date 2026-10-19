package com.vrms.controller;

import com.vrms.model.RentalInquiry;
import com.vrms.service.InquiryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/inquiries")
@CrossOrigin(origins = "*", allowedHeaders = "*")
@Tag(name = "6. Leads & Inquiries", description = "Customer vehicle inquiries, test drive requests, and quote submissions")
public class InquiryController {

    private final InquiryService inquiryService;

    public InquiryController(InquiryService inquiryService) {
        this.inquiryService = inquiryService;
    }

    @Operation(summary = "List All Inquiries", description = "Retrieves all customer inquiries and leads submitted through the web storefront.")
    @GetMapping
    public ResponseEntity<List<RentalInquiry>> getInquiries() {
        return ResponseEntity.ok(inquiryService.getAllInquiries());
    }

    @Operation(summary = "Submit Inquiry", description = "Receives a new vehicle inquiry from the storefront.")
    @PostMapping
    public ResponseEntity<RentalInquiry> submitInquiry(@RequestBody RentalInquiry inquiry) {
        return ResponseEntity.ok(inquiryService.submitInquiry(inquiry));
    }
}

