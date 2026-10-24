package com.trustguard.insurance.repository;

import com.trustguard.insurance.entity.Payment;
import com.trustguard.insurance.entity.PaymentStatus;
import com.trustguard.insurance.entity.Policy;
import com.trustguard.insurance.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface PaymentRepository extends JpaRepository<Payment, UUID> {

    List<Payment> findByPolicyOrderByDueDateDesc(Policy policy);

    @Query("select p from Payment p where p.policy.user = :user order by p.dueDate desc")
    List<Payment> findAllForUser(@Param("user") User user);

    long countByStatus(PaymentStatus status);

    @Query("select coalesce(sum(p.amount), 0) from Payment p where p.status = 'PAID'")
    BigDecimal sumPaid();

    @Query("select coalesce(sum(p.amount), 0) from Payment p where p.status = 'PAID' and p.paidDate >= :from")
    BigDecimal sumPaidSince(@Param("from") LocalDate from);
}
