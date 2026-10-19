package com.vrms.service.impl;

import com.vrms.exception.ResourceNotFoundException;
import com.vrms.model.BannerItem;
import com.vrms.repository.BannerItemRepository;
import com.vrms.service.BannerService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class BannerServiceImpl implements BannerService {

    private final BannerItemRepository bannerItemRepository;

    public BannerServiceImpl(BannerItemRepository bannerItemRepository) {
        this.bannerItemRepository = bannerItemRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public List<BannerItem> getAllBanners() {
        return bannerItemRepository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public BannerItem getBannerById(String id) {
        return bannerItemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Banner not found with ID: " + id));
    }

    @Override
    public BannerItem saveBanner(BannerItem banner) {
        if (banner.getId() == null || banner.getId().trim().isEmpty()) {
            banner.setId("b-" + System.currentTimeMillis());
        }
        return bannerItemRepository.save(banner);
    }

    @Override
    public void deleteBanner(String id) {
        if (!bannerItemRepository.existsById(id)) {
            throw new ResourceNotFoundException("Cannot delete: Banner not found with ID: " + id);
        }
        bannerItemRepository.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public long count() {
        return bannerItemRepository.count();
    }
}

