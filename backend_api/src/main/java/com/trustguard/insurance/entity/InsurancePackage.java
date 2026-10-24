package com.trustguard.insurance.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "insurance_packages")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InsurancePackage {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private InsuranceCategory category;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String tagline;

    @Column(nullable = false, length = 2000)
    private String description;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal monthlyPrice;

    @Column(nullable = false, precision = 14, scale = 2)
    private BigDecimal coverageAmount;

    @Column(nullable = false)
    private int durationMonths;

    @ElementCollection
    @CollectionTable(name = "package_benefits", joinColumns = @JoinColumn(name = "package_id"))
    @Column(name = "benefit", length = 500)
    @OrderColumn(name = "position")
    @Builder.Default
    private List<String> benefits = new ArrayList<>();

    @Builder.Default
    private boolean featured = false;

    @Builder.Default
    private boolean active = true;

    @Column(nullable = false)
    @Builder.Default
    private double rating = 4.7;

    @Builder.Default
    private int reviewCount = 0;

    @Column(nullable = false)
    @Builder.Default
    private int waitingPeriodDays = 30;

    @Column(nullable = false)
    @Builder.Default
    private int claimWindowDays = 90;

    @Column(length = 3000)
    private String claimPolicy;

    /** Pipe-separated lists keep these compact without extra join tables. */
    @Column(length = 2000)
    private String claimDocuments;

    @Column(length = 2000)
    private String exclusions;

    @Column(length = 5000)
    private String legalTerms;
}
