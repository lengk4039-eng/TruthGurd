package com.trustguard.insurance.service;

import com.trustguard.insurance.dto.PackageResponse;
import com.trustguard.insurance.dto.admin.PackageRequest;
import com.trustguard.insurance.entity.InsuranceCategory;
import com.trustguard.insurance.entity.InsurancePackage;
import com.trustguard.insurance.exception.ResourceNotFoundException;
import com.trustguard.insurance.repository.InsurancePackageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PackageService {

    private final InsurancePackageRepository packageRepository;

    public List<PackageResponse> list(InsuranceCategory category) {
        List<InsurancePackage> packages = category == null
                ? packageRepository.findByActiveTrue()
                : packageRepository.findByActiveTrueAndCategory(category);
        return packages.stream().map(PackageResponse::from).toList();
    }

    public List<PackageResponse> featured() {
        return packageRepository.findByActiveTrueAndFeaturedTrue().stream().map(PackageResponse::from).toList();
    }

    public PackageResponse getById(UUID id) {
        return PackageResponse.from(findEntity(id));
    }

    InsurancePackage findEntity(UUID id) {
        return packageRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Package not found."));
    }

    @Transactional
    public PackageResponse create(PackageRequest request) {
        InsurancePackage pkg = InsurancePackage.builder()
                .category(request.category())
                .name(request.name())
                .tagline(request.tagline())
                .description(request.description())
                .monthlyPrice(request.monthlyPrice())
                .coverageAmount(request.coverageAmount())
                .durationMonths(request.durationMonths())
                .benefits(request.benefits() == null ? List.of() : request.benefits())
                .featured(request.featured())
                .active(request.active())
                .waitingPeriodDays(request.waitingPeriodDays() == null ? 30 : request.waitingPeriodDays())
                .claimWindowDays(request.claimWindowDays() == null ? 90 : request.claimWindowDays())
                .build();
        return PackageResponse.from(packageRepository.save(pkg));
    }

    @Transactional
    public PackageResponse update(UUID id, PackageRequest request) {
        InsurancePackage pkg = findEntity(id);
        pkg.setCategory(request.category());
        pkg.setName(request.name());
        pkg.setTagline(request.tagline());
        pkg.setDescription(request.description());
        pkg.setMonthlyPrice(request.monthlyPrice());
        pkg.setCoverageAmount(request.coverageAmount());
        pkg.setDurationMonths(request.durationMonths());
        pkg.setBenefits(request.benefits() == null ? List.of() : request.benefits());
        pkg.setFeatured(request.featured());
        pkg.setActive(request.active());
        if (request.waitingPeriodDays() != null) pkg.setWaitingPeriodDays(request.waitingPeriodDays());
        if (request.claimWindowDays() != null) pkg.setClaimWindowDays(request.claimWindowDays());
        return PackageResponse.from(packageRepository.save(pkg));
    }

    @Transactional
    public void delete(UUID id) {
        InsurancePackage pkg = findEntity(id);
        pkg.setActive(false);
        packageRepository.save(pkg);
    }

    public List<PackageResponse> adminList() {
        return packageRepository.findAll().stream().map(PackageResponse::from).toList();
    }
}
