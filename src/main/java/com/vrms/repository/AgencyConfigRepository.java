package com.vrms.repository;

import com.vrms.model.AgencyConfig;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AgencyConfigRepository extends JpaRepository<AgencyConfig, String> {
}

