package com.vrms.service.impl;

import com.vrms.model.AgencyConfig;
import com.vrms.repository.AgencyConfigRepository;
import com.vrms.service.AgencyService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class AgencyServiceImpl implements AgencyService {

    private final AgencyConfigRepository agencyConfigRepository;

    public AgencyServiceImpl(AgencyConfigRepository agencyConfigRepository) {
        this.agencyConfigRepository = agencyConfigRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public AgencyConfig getAgencyConfig() {
        return agencyConfigRepository.findById("default").orElseGet(() -> {
            AgencyConfig def = AgencyConfig.builder().id("default").build();
            return agencyConfigRepository.save(def);
        });
    }

    @Override
    public AgencyConfig updateAgencyConfig(AgencyConfig config) {
        config.setId("default");
        return agencyConfigRepository.save(config);
    }
}

