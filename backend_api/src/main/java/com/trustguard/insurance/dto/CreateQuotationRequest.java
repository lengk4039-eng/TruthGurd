package com.trustguard.insurance.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record CreateQuotationRequest(
        @NotNull String packageId,
        @Min(1) int preferredPlanMonths,
        String notes
) {
}
