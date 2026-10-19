package com.vrms.repository;

import com.vrms.model.BannerItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BannerItemRepository extends JpaRepository<BannerItem, String> {
    List<BannerItem> findByActiveTrue();
}

