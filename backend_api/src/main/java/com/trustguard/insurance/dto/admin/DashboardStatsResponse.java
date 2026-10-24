package com.trustguard.insurance.dto.admin;

import java.math.BigDecimal;

public record DashboardStatsResponse(
        long totalUsers,
        long activePolicies,
        long pendingPayments,
        long overduePayments,
        BigDecimal monthlyRevenue,
        BigDecimal totalRevenue
) {
}
