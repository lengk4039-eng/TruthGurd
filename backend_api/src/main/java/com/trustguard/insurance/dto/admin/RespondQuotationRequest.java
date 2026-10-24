package com.trustguard.insurance.dto.admin;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;
import java.time.LocalDate;

public record RespondQuotationRequest(
        @NotNull @Positive BigDecimal quotedPremium,
        LocalDate validUntil,
        String salesNotes
) {
}
