package com.trustguard.insurance.service;

import com.trustguard.insurance.entity.PaymentMethod;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.UUID;

@Service
public class SimulatedPaymentGateway implements PaymentGateway {

    @Override
    public GatewayResult charge(BigDecimal amount, PaymentMethod method) {
        String ref = "SIM-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        return new GatewayResult(true, ref, "Payment simulated successfully.");
    }
}
