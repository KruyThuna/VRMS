package com.vrms.service;

import com.vrms.model.BannerItem;
import java.util.List;

public interface BannerService {
    List<BannerItem> getAllBanners();
    BannerItem getBannerById(String id);
    BannerItem saveBanner(BannerItem banner);
    void deleteBanner(String id);
    long count();
}

