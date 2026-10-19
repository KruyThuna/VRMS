package com.vrms.service.impl;

import com.vrms.exception.ResourceNotFoundException;
import com.vrms.model.Rental;
import com.vrms.repository.RentalRepository;
import com.vrms.service.RentalService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class RentalServiceImpl implements RentalService {

    private final RentalRepository rentalRepository;

    public RentalServiceImpl(RentalRepository rentalRepository) {
        this.rentalRepository = rentalRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public List<Rental> getAllRentals() {
        return rentalRepository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public Rental getRentalById(String id) {
        return rentalRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Rental booking not found with ID: " + id));
    }

    @Override
    public Rental saveRental(Rental rental) {
        if (rental.getId() == null || rental.getId().trim().isEmpty()) {
            rental.setId("R-" + System.currentTimeMillis());
        }
        return rentalRepository.save(rental);
    }

    @Override
    public void deleteRental(String id) {
        if (!rentalRepository.existsById(id)) {
            throw new ResourceNotFoundException("Cannot delete: Rental booking not found with ID: " + id);
        }
        rentalRepository.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public long count() {
        return rentalRepository.count();
    }
}

