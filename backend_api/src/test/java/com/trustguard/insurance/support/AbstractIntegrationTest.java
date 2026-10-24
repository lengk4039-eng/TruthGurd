package com.trustguard.insurance.support;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;

/**
 * Base for full-stack tests: boots the real Spring context against the
 * {@code trustguard_test} database on the same Postgres the app uses for
 * local dev (see {@code docker-compose.yml} / {@code application-test.yml}),
 * and wraps every test method in a transaction that's rolled back
 * afterwards, so tests don't need to clean up after themselves or worry
 * about ordering.
 *
 * <p>Requires {@code docker compose up -d db} to be running first — same
 * prerequisite as running the app itself locally. (We'd normally reach for
 * Testcontainers to spin up an ephemeral database instead, but its Docker
 * Engine API client isn't yet compatible with the Docker Desktop version in
 * this environment; this is the pragmatic equivalent.)
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
public abstract class AbstractIntegrationTest {

    @Autowired
    protected MockMvc mockMvc;

    @Autowired
    protected ObjectMapper objectMapper;

    /** Seeded by V2__seed_data.sql — see that file for the full fixture set. */
    public static final String SEEDED_ADMIN_EMAIL = "admin@trustguard.example";
    public static final String SEEDED_CUSTOMER_EMAIL = "jordan.lee@email.com";
    public static final String SEEDED_PASSWORD = "Password123";
    public static final String SEEDED_HEALTH_BASIC_PACKAGE_ID = "a0000000-0000-0000-0000-000000000001";

    protected String loginAndGetToken(String email, String password) throws Exception {
        var response = mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("email", email, "password", password))))
                .andReturn().getResponse().getContentAsString();
        return objectMapper.readTree(response).get("accessToken").asText();
    }

    /** Registers a fresh, uniquely-emailed customer for tests that need to start from a clean account. */
    protected String registerNewCustomerAndGetToken() throws Exception {
        String email = "test-" + UUID.randomUUID() + "@example.com";
        var response = mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "fullName", "Test Customer",
                                "email", email,
                                "phone", "+1 555-0000",
                                "password", "TestPassword123"))))
                .andReturn().getResponse().getContentAsString();
        return objectMapper.readTree(response).get("accessToken").asText();
    }
}
