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

class PackageIntegrationTest extends AbstractIntegrationTest {

    @Test
    void listingPackagesReturnsAllTenSeededOnes() throws Exception {
        mockMvc.perform(get("/api/v1/packages"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(10));
    }

    @Test
    void filteringByCategoryReturnsOnlyThatCategory() throws Exception {
        mockMvc.perform(get("/api/v1/packages").param("category", "HEALTH"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].category").value("HEALTH"))
                .andExpect(jsonPath("$[1].category").value("HEALTH"));
    }

    @Test
    void gettingASpecificSeededPackageByIdWorks() throws Exception {
        mockMvc.perform(get("/api/v1/packages/" + SEEDED_HEALTH_BASIC_PACKAGE_ID))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Health Shield Basic"));
    }

    @Test
    void gettingAPackageThatDoesNotExistReturns404() throws Exception {
        mockMvc.perform(get("/api/v1/packages/" + UUID.randomUUID()))
                .andExpect(status().isNotFound());
    }

    @Test
    void aCustomerCannotCreatePackages() throws Exception {
        String customerToken = loginAndGetToken(SEEDED_CUSTOMER_EMAIL, SEEDED_PASSWORD);

        mockMvc.perform(post("/api/v1/admin/packages")
                        .header("Authorization", "Bearer " + customerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(newPackagePayload())))
                .andExpect(status().isForbidden());
    }

    @Test
    void anAdminCanCreateAPackageAndSeeItInTheCatalog() throws Exception {
        String adminToken = loginAndGetToken(SEEDED_ADMIN_EMAIL, SEEDED_PASSWORD);

        mockMvc.perform(post("/api/v1/admin/packages")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(newPackagePayload())))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value("Pet Wellness Plan"));

        mockMvc.perform(get("/api/v1/packages"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(11));
    }

    private Map<String, Object> newPackagePayload() {
        return Map.of(
                "category", "HEALTH",
                "name", "Pet Wellness Plan",
                "tagline", "Keep your pet healthy",
                "description", "Vet visits and vaccinations covered.",
                "monthlyPrice", 20,
                "coverageAmount", 5000,
                "durationMonths", 12,
                "benefits", java.util.List.of("Vet visits", "Vaccinations"),
                "featured", false,
                "active", true);
    }
}
