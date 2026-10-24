package com.trustguard.insurance.controller.admin;

import com.trustguard.insurance.dto.admin.DashboardStatsResponse;
import com.trustguard.insurance.service.AdminDashboardService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/dashboard")
@RequiredArgsConstructor
@Tag(name = "Admin · Dashboard")
public class AdminDashboardController {

    private final AdminDashboardService dashboardService;

    @GetMapping("/stats")
    public DashboardStatsResponse stats() {
        return dashboardService.stats();
    }
}
