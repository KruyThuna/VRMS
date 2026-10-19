package com.vrms.service;

import com.vrms.model.Rental;
import java.util.List;

public interface RentalService {
    List<Rental> getAllRentals();
    Rental getRentalById(String id);
    Rental saveRental(Rental rental);
    void deleteRental(String id);
    long count();
}

