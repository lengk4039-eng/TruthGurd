package com.trustguard.insurance.dto;

import com.trustguard.insurance.entity.Quotation;
import com.trustguard.insurance.entity.QuotationStatus;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

public record QuotationResponse(
        String id,
        String packageId,
        PackageResponse insurancePackage,
        int preferredPlanMonths,
        String notes,
        QuotationStatus status,
        BigDecimal quotedPremium,
        LocalDate validUntil,
        String salesNotes,
        Instant createdAt,
        String policyId,
        String customerName,
        String customerEmail
) {
    public static QuotationResponse from(Quotation q) {
        return new QuotationResponse(
                q.getId().toString(),
                q.getInsurancePackage().getId().toString(),
                PackageResponse.from(q.getInsurancePackage()),
                q.getPreferredPlanMonths(),
                q.getNotes() == null ? "" : q.getNotes(),
                q.getStatus(),
                q.getQuotedPremium(),
                q.getValidUntil(),
                q.getSalesNotes(),
                q.getCreatedAt(),
                q.getPolicy() != null ? q.getPolicy().getId().toString() : null,
                q.getUser() != null ? q.getUser().getFullName() : null,
                q.getUser() != null ? q.getUser().getEmail() : null
        );
    }
}
