package com.trustguard.insurance.dto.auth;

/**
 * A short-lived proof that {@link VerifyPolicyRequest} matched an unclaimed
 * policy, to be presented by {@link RegisterRequest}.
 */
public record VerifyPolicyResponse(
        String verificationToken,
        String policyNumber,
        String packageName
) {
}
