package com.trustguard.insurance.dto;

import com.trustguard.insurance.entity.Payment;
import com.trustguard.insurance.entity.PaymentMethod;
import com.trustguard.insurance.entity.PaymentStatus;

import java.math.BigDecimal;
import java.time.LocalDate;

public record PaymentResponse(
        String id,
        String policyId,
        String policyName,
        String invoiceNumber,
        BigDecimal amount,
        LocalDate dueDate,
        LocalDate paidDate,
        PaymentStatus status,
        PaymentMethod method
) {
    public static PaymentResponse from(Payment payment) {
        return new PaymentResponse(
                payment.getId().toString(),
                payment.getPolicy().getId().toString(),
                payment.getPolicy().getInsurancePackage().getName(),
                payment.getInvoiceNumber(),
                payment.getAmount(),
                payment.getDueDate(),
                payment.getPaidDate(),
                effectiveStatus(payment),
                payment.getMethod()
        );
    }

    private static PaymentStatus effectiveStatus(Payment payment) {
        if (payment.getStatus() != PaymentStatus.PAID
                && payment.getStatus() != PaymentStatus.OVERDUE
                && payment.getDueDate() != null
                && payment.getDueDate().isBefore(LocalDate.now())) {
            return PaymentStatus.OVERDUE;
        }
        return payment.getStatus();
    }
}
