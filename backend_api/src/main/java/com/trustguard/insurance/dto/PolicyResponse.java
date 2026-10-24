package com.trustguard.insurance.dto;

import com.trustguard.insurance.entity.Policy;
import com.trustguard.insurance.entity.PolicySource;
import com.trustguard.insurance.entity.PolicyStatus;

import java.math.BigDecimal;
import java.time.LocalDate;

public record PolicyResponse(
        String id,
        String policyNumber,
        PackageResponse insurancePackage,
        PolicyStatus status,
        PolicySource source,
        LocalDate startDate,
        LocalDate endDate,
        BigDecimal totalPremium,
        BigDecimal amountPaid
) {
    public static PolicyResponse from(Policy policy) {
        return new PolicyResponse(
                policy.getId().toString(),
                policy.getPolicyNumber(),
                PackageResponse.from(policy.getInsurancePackage()),
                policy.getStatus(),
                policy.getSource(),
                policy.getStartDate(),
                policy.getEndDate(),
                policy.getTotalPremium(),
                policy.getAmountPaid()
        );
    }
}
