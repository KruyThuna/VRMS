package com.vrms.service;

import com.vrms.model.AgencyConfig;

public interface AgencyService {
    AgencyConfig getAgencyConfig();
    AgencyConfig updateAgencyConfig(AgencyConfig config);
}

