package com.trustguard.insurance.dto.admin;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Lets an admin pre-register a policy sold offline/by an agent, before the
 * customer ever creates an account. The customer later claims it via
 * POST /api/v1/auth/link-existing-policy using policyNumber + dateOfBirth.
 */
public record CreateOfflinePolicyRequest(
        @NotBlank String policyNumber,
        @NotNull String packageId,
        @NotNull LocalDate dateOfBirth,
        @NotNull LocalDate startDate,
        @NotNull LocalDate endDate,
        @NotNull @PositiveOrZero BigDecimal totalPremium,
        @PositiveOrZero BigDecimal amountPaid
) {
}
