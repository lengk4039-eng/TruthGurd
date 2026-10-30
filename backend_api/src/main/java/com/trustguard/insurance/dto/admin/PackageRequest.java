package com.trustguard.insurance.dto.admin;

import com.trustguard.insurance.entity.InsuranceCategory;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;

import java.math.BigDecimal;
import java.util.List;

public record PackageRequest(
        @NotNull InsuranceCategory category,
        @NotBlank String name,
        @NotBlank String tagline,
        @NotBlank String description,
        @NotNull @PositiveOrZero BigDecimal monthlyPrice,
        @NotNull @PositiveOrZero BigDecimal coverageAmount,
        @Min(1) int durationMonths,
        List<String> benefits,
        boolean featured,
        boolean active,
        @PositiveOrZero Integer waitingPeriodDays,
        @Min(1) Integer claimWindowDays
) {
}
