package com.trustguard.insurance.dto.admin;

import com.trustguard.insurance.entity.PaymentMethod;
import jakarta.validation.constraints.NotNull;

public record AdminMarkPaidRequest(@NotNull PaymentMethod method) {
}
