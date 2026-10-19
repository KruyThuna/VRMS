package com.vrms.service;

import com.vrms.model.RentalInquiry;
import java.util.List;

public interface InquiryService {
    List<RentalInquiry> getAllInquiries();
    RentalInquiry submitInquiry(RentalInquiry inquiry);
}

