package com.trustguard.insurance.dto;

import jakarta.validation.constraints.NotNull;

public record AcceptQuotationRequest(
        @NotNull String policyId
) {
}
