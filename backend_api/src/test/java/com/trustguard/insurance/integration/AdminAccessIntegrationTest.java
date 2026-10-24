package com.trustguard.insurance.integration;

import com.trustguard.insurance.support.AbstractIntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

import java.time.LocalDate;
import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class AdminAccessIntegrationTest extends AbstractIntegrationTest {

    private static final String SEEDED_OVERDUE_PAYMENT_ID = "c0000000-0000-0000-0000-000000000005";

    @Test
    void aCustomerTokenIsRejectedFromEveryAdminRoute() throws Exception {
        String customerToken = loginAndGetToken(SEEDED_CUSTOMER_EMAIL, SEEDED_PASSWORD);

        mockMvc.perform(get("/api/v1/admin/dashboard/stats").header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isForbidden());
        mockMvc.perform(get("/api/v1/admin/users").header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isForbidden());
        mockMvc.perform(get("/api/v1/admin/policies").header("Authorization", "Bearer " + customerToken))
                .andExpect(status().isForbidden());
    }

    @Test
    void anAdminTokenCanReadDashboardStats() throws Exception {
        String adminToken = loginAndGetToken(SEEDED_ADMIN_EMAIL, SEEDED_PASSWORD);

        mockMvc.perform(get("/api/v1/admin/dashboard/stats").header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalUsers").isNumber())
                .andExpect(jsonPath("$.activePolicies").isNumber());
    }

    @Test
    void adminRegistersAnOfflinePolicyAndTheCustomerLinksIt() throws Exception {
        String adminToken = loginAndGetToken(SEEDED_ADMIN_EMAIL, SEEDED_PASSWORD);
        String policyNumber = "TG-OFFLINE-" + System.currentTimeMillis() % 100000;

        mockMvc.perform(post("/api/v1/admin/policies/offline")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "policyNumber", policyNumber,
                                "packageId", SEEDED_HEALTH_BASIC_PACKAGE_ID,
                                "dateOfBirth", "1985-03-20",
                                "startDate", LocalDate.now().toString(),
                                "endDate", LocalDate.now().plusYears(1).toString(),
                                "totalPremium", 540.00,
                                "amountPaid", 0))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.status").value("PENDING"));

        String customerToken = registerNewCustomerAndGetToken();
        mockMvc.perform(post("/api/v1/auth/link-existing-policy")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("policyNumber", policyNumber, "dateOfBirth", "1985-03-20"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("ACTIVE"));
    }

    @Test
    void adminCanMarkASeededOverduePaymentAsPaid() throws Exception {
        String adminToken = loginAndGetToken(SEEDED_ADMIN_EMAIL, SEEDED_PASSWORD);

        mockMvc.perform(post("/api/v1/admin/payments/" + SEEDED_OVERDUE_PAYMENT_ID + "/mark-paid")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("method", "BANK_TRANSFER"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("PAID"));
    }
}
