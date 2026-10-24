package com.trustguard.insurance.repository;

import com.trustguard.insurance.entity.InsuranceCategory;
import com.trustguard.insurance.entity.InsurancePackage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface InsurancePackageRepository extends JpaRepository<InsurancePackage, UUID> {
    List<InsurancePackage> findByActiveTrue();
    List<InsurancePackage> findByActiveTrueAndCategory(InsuranceCategory category);
    List<InsurancePackage> findByActiveTrueAndFeaturedTrue();
}
