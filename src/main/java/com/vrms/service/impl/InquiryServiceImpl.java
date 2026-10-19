package com.vrms.service.impl;

import com.vrms.model.RentalInquiry;
import com.vrms.repository.RentalInquiryRepository;
import com.vrms.service.InquiryService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@Transactional
public class InquiryServiceImpl implements InquiryService {

    private final RentalInquiryRepository rentalInquiryRepository;

    public InquiryServiceImpl(RentalInquiryRepository rentalInquiryRepository) {
        this.rentalInquiryRepository = rentalInquiryRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public List<RentalInquiry> getAllInquiries() {
        return rentalInquiryRepository.findAll();
    }

    @Override
    public RentalInquiry submitInquiry(RentalInquiry inquiry) {
        inquiry.setCreatedAt(LocalDateTime.now());
        return rentalInquiryRepository.save(inquiry);
    }
}

