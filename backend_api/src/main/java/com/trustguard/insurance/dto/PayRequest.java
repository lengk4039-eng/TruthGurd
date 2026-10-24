package com.trustguard.insurance.dto;

import com.trustguard.insurance.entity.PaymentMethod;
import jakarta.validation.constraints.NotNull;

public record PayRequest(@NotNull PaymentMethod method) {
}
