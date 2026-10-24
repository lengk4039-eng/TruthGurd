package com.trustguard.insurance.controller.admin;

import com.trustguard.insurance.dto.PolicyResponse;
import com.trustguard.insurance.dto.admin.CreateOfflinePolicyRequest;
import com.trustguard.insurance.service.PolicyService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/policies")
@RequiredArgsConstructor
@Tag(name = "Admin · Policies")
public class AdminPolicyController {

    private final PolicyService policyService;

    @GetMapping
    public List<PolicyResponse> list() {
        return policyService.adminList();
    }

    /** Pre-registers a policy sold offline/by an agent, before the customer has an account. */
    @PostMapping("/offline")
    @ResponseStatus(HttpStatus.CREATED)
    public PolicyResponse createOffline(@Valid @RequestBody CreateOfflinePolicyRequest request) {
        return policyService.adminCreateOfflinePolicy(request);
    }
}
