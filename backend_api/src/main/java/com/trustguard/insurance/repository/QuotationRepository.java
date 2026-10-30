package com.trustguard.insurance.repository;

import com.trustguard.insurance.entity.Quotation;
import com.trustguard.insurance.entity.QuotationStatus;
import com.trustguard.insurance.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface QuotationRepository extends JpaRepository<Quotation, UUID> {
    List<Quotation> findByUserOrderByCreatedAtDesc(User user);
    List<Quotation> findAllByOrderByCreatedAtDesc();
    long countByStatus(QuotationStatus status);
    long countByUser(User user);
}
