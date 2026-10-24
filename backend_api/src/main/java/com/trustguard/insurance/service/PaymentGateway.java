package com.trustguard.insurance.service;

import com.trustguard.insurance.entity.PaymentMethod;

import java.math.BigDecimal;

/**
 * Charges a payment method for an amount. No real processor is wired up yet
 * — {@link SimulatedPaymentGateway} always succeeds — but controllers and
 * services only depend on this interface, so swapping in Stripe/Midtrans/etc.
 * later means adding one new implementation, not touching call sites.
 */
public interface PaymentGateway {
    GatewayResult charge(BigDecimal amount, PaymentMethod method);

    record GatewayResult(boolean success, String transactionRef, String message) {
    }
}
