package com.trustguard.insurance.dto;

import com.trustguard.insurance.entity.Claim;
import com.trustguard.insurance.entity.ClaimStatus;
import com.trustguard.insurance.entity.ClaimType;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

public record ClaimResponse(
        String id,
        String claimNumber,
        String policyId,
        String policyNumber,
        String policyName,
        ClaimType type,
        ClaimStatus status,
        String description,
        BigDecimal amount,
        LocalDate incidentDate,
        Instant submittedAt,
        Instant reviewedAt,
        Instant updatedAt,
        String reviewNotes,
        String photoUrl,
        String customerName,
        String customerEmail
) {
    public static ClaimResponse from(Claim claim) {
        return new ClaimResponse(
                claim.getId().toString(),
                claim.getClaimNumber(),
                claim.getPolicy().getId().toString(),
                claim.getPolicy().getPolicyNumber(),
                claim.getPolicy().getInsurancePackage().getName(),
                claim.getType(),
                claim.getStatus(),
                claim.getDescription(),
                claim.getAmount(),
                claim.getIncidentDate(),
                claim.getSubmittedAt(),
                claim.getReviewedAt(),
                claim.getUpdatedAt(),
                claim.getReviewNotes(),
                claim.getPhotoUrl(),
                claim.getUser() != null ? claim.getUser().getFullName() : null,
                claim.getUser() != null ? claim.getUser().getEmail() : null
        );
    }
}
