package com.trustguard.insurance.service;

import com.trustguard.insurance.dto.PaymentResponse;
import com.trustguard.insurance.entity.NotificationType;
import com.trustguard.insurance.entity.Payment;
import com.trustguard.insurance.entity.PaymentMethod;
import com.trustguard.insurance.entity.PaymentStatus;
import com.trustguard.insurance.entity.Policy;
import com.trustguard.insurance.entity.Role;
import com.trustguard.insurance.entity.User;
import com.trustguard.insurance.exception.BadRequestException;
import com.trustguard.insurance.exception.ResourceNotFoundException;
import com.trustguard.insurance.repository.PaymentRepository;
import com.trustguard.insurance.repository.PolicyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final PolicyRepository policyRepository;
    private final PaymentGateway paymentGateway;
    private final NotificationService notificationService;

    public List<PaymentResponse> getMyPayments(User user) {
        return paymentRepository.findAllForUser(user).stream().map(PaymentResponse::from).toList();
    }

    public PaymentResponse getById(User requester, UUID id) {
        return PaymentResponse.from(findOwnedOrAdmin(requester, id));
    }

    private Payment findOwnedOrAdmin(User requester, UUID id) {
        Payment payment = paymentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Payment not found."));
        boolean isOwner = payment.getPolicy().getUser() != null
                && payment.getPolicy().getUser().getId().equals(requester.getId());
        if (!isOwner && requester.getRole() != Role.ADMIN) {
            throw new ResourceNotFoundException("Payment not found.");
        }
        return payment;
    }

    @Transactional
    public void createInitialInvoice(Policy policy, PaymentMethod method) {
        PaymentGateway.GatewayResult result = paymentGateway.charge(policy.getTotalPremium(), method);
        Payment payment = Payment.builder()
                .policy(policy)
                .invoiceNumber(generateInvoiceNumber())
                .amount(policy.getTotalPremium())
                .dueDate(LocalDate.now())
                .status(result.success() ? PaymentStatus.PAID : PaymentStatus.FAILED)
                .method(method)
                .transactionRef(result.transactionRef())
                .paidDate(result.success() ? LocalDate.now() : null)
                .build();
        paymentRepository.save(payment);

        if (result.success()) {
            policy.setAmountPaid(policy.getAmountPaid().add(policy.getTotalPremium()));
            policyRepository.save(policy);
        }
    }

    @Transactional
    public PaymentResponse payNow(User user, UUID paymentId, PaymentMethod method) {
        Payment payment = findOwnedOrAdmin(user, paymentId);
        if (payment.getStatus() == PaymentStatus.PAID) {
            throw new BadRequestException("This payment has already been paid.");
        }
        PaymentGateway.GatewayResult result = paymentGateway.charge(payment.getAmount(), method);
        if (!result.success()) {
            payment.setStatus(PaymentStatus.FAILED);
            paymentRepository.save(payment);
            throw new BadRequestException("Payment failed. Please try again.");
        }
        payment.setStatus(PaymentStatus.PAID);
        payment.setPaidDate(LocalDate.now());
        payment.setMethod(method);
        payment.setTransactionRef(result.transactionRef());
        payment = paymentRepository.save(payment);

        Policy policy = payment.getPolicy();
        policy.setAmountPaid(policy.getAmountPaid().add(payment.getAmount()));
        policyRepository.save(policy);

        if (policy.getUser() != null) {
            notificationService.notify(policy.getUser(), NotificationType.PAYMENT,
                    "Payment received", "We received your payment for " + policy.getInsurancePackage().getName() + ".");
        }
        return PaymentResponse.from(payment);
    }

    @Transactional
    public PaymentResponse adminMarkPaid(UUID paymentId, PaymentMethod method) {
        Payment payment = paymentRepository.findById(paymentId)
                .orElseThrow(() -> new ResourceNotFoundException("Payment not found."));
        payment.setStatus(PaymentStatus.PAID);
        payment.setPaidDate(LocalDate.now());
        payment.setMethod(method);
        payment.setTransactionRef("MANUAL-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase());
        payment = paymentRepository.save(payment);

        Policy policy = payment.getPolicy();
        policy.setAmountPaid(policy.getAmountPaid().add(payment.getAmount()));
        policyRepository.save(policy);
        return PaymentResponse.from(payment);
    }

    public List<PaymentResponse> adminList() {
        return paymentRepository.findAll().stream().map(PaymentResponse::from).toList();
    }

    private String generateInvoiceNumber() {
        return "INV-" + LocalDate.now().getYear() + "-" + ThreadLocalRandom.current().nextInt(100000, 999999);
    }
}
