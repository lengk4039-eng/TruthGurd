package com.trustguard.insurance.integration;

import com.trustguard.insurance.support.AbstractIntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

import java.util.Map;
import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class PurchaseAndPaymentIntegrationTest extends AbstractIntegrationTest {

    // From V2__seed_data.sql: pol_1's PENDING and already-PAID invoices.
    private static final String SEEDED_PENDING_PAYMENT_ID = "c0000000-0000-0000-0000-000000000003";
    private static final String SEEDED_PAID_PAYMENT_ID = "c0000000-0000-0000-0000-000000000001";

    @Test
    void purchasingAPackageChargesTheFullAmountImmediatelyAndShowsUpInPoliciesAndPayments() throws Exception {
        String token = registerNewCustomerAndGetToken();

        String purchaseResponse = mockMvc.perform(post("/api/v1/policies/purchase")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "packageId", SEEDED_HEALTH_BASIC_PACKAGE_ID,
                                "durationMonths", 6,
                                "paymentMethod", "CARD",
                                "addOnTotal", 27.00))))
                .andExpect(status().isCreated())
                // 45/mo * 6 + 27 add-on = 297
                .andExpect(jsonPath("$.totalPremium").value(297.00))
                .andExpect(jsonPath("$.amountPaid").value(297.00))
                .andExpect(jsonPath("$.status").value("ACTIVE"))
                .andReturn().getResponse().getContentAsString();
        String policyId = objectMapper.readTree(purchaseResponse).get("id").asText();

        mockMvc.perform(get("/api/v1/policies/me").header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(policyId));

        mockMvc.perform(get("/api/v1/payments/me").header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].status").value("PAID"))
                .andExpect(jsonPath("$[0].amount").value(297.00));
    }

    @Test
    void purchasingAPackageThatDoesNotExistReturns404() throws Exception {
        String token = registerNewCustomerAndGetToken();

        mockMvc.perform(post("/api/v1/policies/purchase")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "packageId", UUID.randomUUID().toString(),
                                "durationMonths", 1,
                                "paymentMethod", "CARD"))))
                .andExpect(status().isNotFound());
    }

    @Test
    void payingASeededPendingInvoiceMarksItPaid() throws Exception {
        String token = loginAndGetToken(SEEDED_CUSTOMER_EMAIL, SEEDED_PASSWORD);

        mockMvc.perform(post("/api/v1/payments/" + SEEDED_PENDING_PAYMENT_ID + "/pay")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("method", "E_WALLET"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("PAID"))
                .andExpect(jsonPath("$.method").value("E_WALLET"));
    }

    @Test
    void payingAnAlreadyPaidInvoiceIsRejected() throws Exception {
        String token = loginAndGetToken(SEEDED_CUSTOMER_EMAIL, SEEDED_PASSWORD);

        mockMvc.perform(post("/api/v1/payments/" + SEEDED_PAID_PAYMENT_ID + "/pay")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("method", "CARD"))))
                .andExpect(status().isBadRequest());
    }

    @Test
    void aCustomerCannotPaySomeoneElsesInvoice() throws Exception {
        String otherCustomerToken = registerNewCustomerAndGetToken();

        mockMvc.perform(post("/api/v1/payments/" + SEEDED_PENDING_PAYMENT_ID + "/pay")
                        .header("Authorization", "Bearer " + otherCustomerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("method", "CARD"))))
                .andExpect(status().isNotFound());
    }
}
