package com.trustguard.insurance.service;

import com.trustguard.insurance.dto.admin.DashboardStatsResponse;
import com.trustguard.insurance.entity.PaymentStatus;
import com.trustguard.insurance.entity.PolicyStatus;
import com.trustguard.insurance.repository.PaymentRepository;
import com.trustguard.insurance.repository.PolicyRepository;
import com.trustguard.insurance.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class AdminDashboardService {

    private final UserRepository userRepository;
    private final PolicyRepository policyRepository;
    private final PaymentRepository paymentRepository;

    public DashboardStatsResponse stats() {
        return new DashboardStatsResponse(
                userRepository.count(),
                policyRepository.countByStatus(PolicyStatus.ACTIVE),
                paymentRepository.countByStatus(PaymentStatus.PENDING),
                paymentRepository.countByStatus(PaymentStatus.OVERDUE),
                paymentRepository.sumPaidSince(LocalDate.now().withDayOfMonth(1)),
                paymentRepository.sumPaid()
        );
    }
}
