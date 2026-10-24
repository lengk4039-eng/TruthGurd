package com.trustguard.insurance.dto;

import com.trustguard.insurance.entity.PaymentMethod;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;

import java.math.BigDecimal;

public record PurchaseRequest(
        @NotNull String packageId,
        @Min(1) int durationMonths,
        @NotNull PaymentMethod paymentMethod,
        @PositiveOrZero BigDecimal addOnTotal,
        String quotationId,
        BigDecimal quotedPremium
) {
    /** Monthly add-on surcharge (e.g. priority claims) selected at checkout, already multiplied by duration. */
    public BigDecimal addOnTotalOrZero() {
        return addOnTotal == null ? BigDecimal.ZERO : addOnTotal;
    }

    public boolean isFromQuotation() {
        return quotationId != null && !quotationId.isBlank();
    }
}
