package com.vrms.service;

import com.vrms.model.Vehicle;
import java.util.List;

public interface VehicleService {
    List<Vehicle> getAllVehicles();
    Vehicle getVehicleById(String id);
    Vehicle saveVehicle(Vehicle vehicle);
    void deleteVehicle(String id);
    long count();
}

