package com.trustguard.insurance.dto;

import com.trustguard.insurance.entity.InsuranceCategory;
import com.trustguard.insurance.entity.InsurancePackage;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;

public record PackageResponse(
        String id,
        InsuranceCategory category,
        String name,
        String tagline,
        String description,
        BigDecimal monthlyPrice,
        BigDecimal coverageAmount,
        int durationMonths,
        List<String> benefits,
        boolean featured,
        double rating,
        int reviewCount,
        int waitingPeriodDays,
        int claimWindowDays,
        String claimPolicy,
        List<String> claimDocuments,
        List<String> exclusions,
        String legalTerms
) {
    public static PackageResponse from(InsurancePackage p) {
        return new PackageResponse(
                p.getId().toString(),
                p.getCategory(),
                p.getName(),
                p.getTagline(),
                p.getDescription(),
                p.getMonthlyPrice(),
                p.getCoverageAmount(),
                p.getDurationMonths(),
                p.getBenefits(),
                p.isFeatured(),
                p.getRating(),
                p.getReviewCount(),
                p.getWaitingPeriodDays(),
                p.getClaimWindowDays(),
                p.getClaimPolicy(),
                split(p.getClaimDocuments()),
                split(p.getExclusions()),
                p.getLegalTerms()
        );
    }

    private static List<String> split(String value) {
        if (value == null || value.isBlank()) return List.of();
        return Arrays.stream(value.split("\\|"))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toList();
    }
}
