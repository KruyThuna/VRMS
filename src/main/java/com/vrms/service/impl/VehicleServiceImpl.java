package com.vrms.service.impl;

import com.vrms.exception.ResourceNotFoundException;
import com.vrms.model.Vehicle;
import com.vrms.repository.VehicleRepository;
import com.vrms.service.VehicleService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class VehicleServiceImpl implements VehicleService {

    private final VehicleRepository vehicleRepository;

    public VehicleServiceImpl(VehicleRepository vehicleRepository) {
        this.vehicleRepository = vehicleRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public List<Vehicle> getAllVehicles() {
        return vehicleRepository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public Vehicle getVehicleById(String id) {
        return vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle not found with ID: " + id));
    }

    @Override
    public Vehicle saveVehicle(Vehicle vehicle) {
        if (vehicle.getId() == null || vehicle.getId().trim().isEmpty() || "null".equalsIgnoreCase(vehicle.getId())) {
            vehicle.setId("v-" + System.currentTimeMillis());
        }
        if (vehicle.getName() == null || vehicle.getName().trim().isEmpty() || "null".equalsIgnoreCase(vehicle.getName())) {
            vehicle.setName("Vehicle");
        }
        if (vehicle.getBrand() == null || vehicle.getBrand().trim().isEmpty() || "null".equalsIgnoreCase(vehicle.getBrand())) {
            vehicle.setBrand("DRIVELINE");
        }
        if (vehicle.getPlate() == null || vehicle.getPlate().trim().isEmpty() || "null".equalsIgnoreCase(vehicle.getPlate())) {
            vehicle.setPlate("1-AUTO");
        }
        if (vehicle.getType() == null || vehicle.getType().trim().isEmpty() || "null".equalsIgnoreCase(vehicle.getType())) {
            vehicle.setType("SUV");
        }
        if (vehicle.getTransmission() == null || vehicle.getTransmission().trim().isEmpty() || "null".equalsIgnoreCase(vehicle.getTransmission())) {
            vehicle.setTransmission("Automatic");
        }
        if (vehicle.getFuel() == null || vehicle.getFuel().trim().isEmpty() || "null".equalsIgnoreCase(vehicle.getFuel())) {
            vehicle.setFuel("Petrol");
        }
        if (vehicle.getEngine() == null || vehicle.getEngine().trim().isEmpty() || "null".equalsIgnoreCase(vehicle.getEngine())) {
            vehicle.setEngine("2.0L TURBO ENGINE");
        }
        if (vehicle.getHorsepower() == null || vehicle.getHorsepower().trim().isEmpty() || "null".equalsIgnoreCase(vehicle.getHorsepower())) {
            vehicle.setHorsepower("250 HP");
        }
        if (vehicle.getTopSpeed() == null || vehicle.getTopSpeed().trim().isEmpty() || "null".equalsIgnoreCase(vehicle.getTopSpeed())) {
            vehicle.setTopSpeed("220 KM/H");
        }
        if (vehicle.getAcceleration() == null || vehicle.getAcceleration().trim().isEmpty() || "null".equalsIgnoreCase(vehicle.getAcceleration())) {
            vehicle.setAcceleration("0-100 IN 6.5S");
        }
        if (vehicle.getTagline() == null || vehicle.getTagline().trim().isEmpty() || "null".equalsIgnoreCase(vehicle.getTagline())) {
            vehicle.setTagline("PREMIUM LUXURY RENTAL");
        }
        if (vehicle.getSeats() <= 0) {
            vehicle.setSeats(5);
        }
        if (vehicle.getYear() <= 0) {
            vehicle.setYear(2025);
        }
        if (vehicle.getDailyCents() <= 0 && vehicle.getRate() > 0) {
            vehicle.setDailyCents(vehicle.getRate());
        } else if (vehicle.getDailyCents() <= 0) {
            vehicle.setDailyCents(5500);
        }
        if (vehicle.getImageUrl() != null && ("null".equalsIgnoreCase(vehicle.getImageUrl().trim()) || vehicle.getImageUrl().trim().isEmpty())) {
            vehicle.setImageUrl(null);
        }
        return vehicleRepository.save(vehicle);
    }

    @Override
    public void deleteVehicle(String id) {
        if (!vehicleRepository.existsById(id)) {
            throw new ResourceNotFoundException("Cannot delete: Vehicle not found with ID: " + id);
        }
        vehicleRepository.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public long count() {
        return vehicleRepository.count();
    }
}

