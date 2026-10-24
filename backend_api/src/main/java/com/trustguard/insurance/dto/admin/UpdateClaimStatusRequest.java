package com.trustguard.insurance.dto.admin;

import com.trustguard.insurance.entity.ClaimStatus;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record UpdateClaimStatusRequest(
        @NotNull ClaimStatus status,
        @Size(max = 2000) String reviewNotes
) {
}
