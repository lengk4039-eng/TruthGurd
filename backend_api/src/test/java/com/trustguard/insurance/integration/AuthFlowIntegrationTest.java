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

class AuthFlowIntegrationTest extends AbstractIntegrationTest {

    @Test
    void registerCreatesAnAccountAndReturnsTokens() throws Exception {
        String email = "new-" + UUID.randomUUID() + "@example.com";
        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "fullName", "New Customer",
                                "email", email,
                                "phone", "+1 555-9999",
                                "password", "StrongPass123"))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.accessToken").isNotEmpty())
                .andExpect(jsonPath("$.refreshToken").isNotEmpty())
                .andExpect(jsonPath("$.user.email").value(email))
                .andExpect(jsonPath("$.user.role").value("CUSTOMER"));
    }

    @Test
    void registeringWithAnEmailAlreadyInUseIsRejected() throws Exception {
        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "fullName", "Duplicate",
                                "email", SEEDED_CUSTOMER_EMAIL,
                                "phone", "+1 555-0000",
                                "password", "StrongPass123"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value(org.hamcrest.Matchers.containsString("already exists")));
    }

    @Test
    void loginWithTheSeededCustomerSucceeds() throws Exception {
        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", SEEDED_CUSTOMER_EMAIL, "password", SEEDED_PASSWORD))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.user.email").value(SEEDED_CUSTOMER_EMAIL));
    }

    @Test
    void loginWithTheWrongPasswordIsRejected() throws Exception {
        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", SEEDED_CUSTOMER_EMAIL, "password", "totally-wrong"))))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void aProtectedEndpointRejectsRequestsWithNoToken() throws Exception {
        mockMvc.perform(get("/api/v1/policies/me"))
                .andExpect(status().is4xxClientError());
    }

    @Test
    void linkingAnExistingPolicyWithTheCorrectDetailsSucceeds() throws Exception {
        String token = registerNewCustomerAndGetToken();

        mockMvc.perform(post("/api/v1/auth/link-existing-policy")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("policyNumber", "TG-OFFLINE-7734", "dateOfBirth", "1990-05-12"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.policyNumber").value("TG-OFFLINE-7734"))
                .andExpect(jsonPath("$.status").value("ACTIVE"));
    }

    @Test
    void linkingAnExistingPolicyWithTheWrongDateOfBirthFails() throws Exception {
        String token = registerNewCustomerAndGetToken();

        mockMvc.perform(post("/api/v1/auth/link-existing-policy")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("policyNumber", "TG-OFFLINE-7734", "dateOfBirth", "2000-01-01"))))
                .andExpect(status().isBadRequest());
    }
}
