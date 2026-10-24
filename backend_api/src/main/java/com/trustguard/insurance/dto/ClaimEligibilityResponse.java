package com.trustguard.insurance.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Pre-flight check shown before the claim form. {@code eligible} covers hard
 * blockers (inactive cover, unpaid premium). {@code withinWaitingPeriod} is
 * advisory: only accident claims may be filed during that window.
 */
public record ClaimEligibilityResponse(
        String policyId,
        boolean eligible,
        String code,
        String title,
        String message,
        boolean withinWaitingPeriod,
        LocalDate waitingPeriodEndsAt,
        String overduePaymentId,
        BigDecimal overdueAmount,
        LocalDate overdueDueDate,
        int waitingPeriodDays,
        int claimWindowDays
) {
}
