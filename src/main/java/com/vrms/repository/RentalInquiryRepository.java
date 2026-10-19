package com.vrms.repository;

import com.vrms.model.RentalInquiry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RentalInquiryRepository extends JpaRepository<RentalInquiry, Long> {
}

