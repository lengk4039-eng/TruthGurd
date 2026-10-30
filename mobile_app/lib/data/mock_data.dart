import '../core/models/app_notification.dart';
import '../core/models/app_user.dart';
import '../core/models/insurance_category.dart';
import '../core/models/insurance_package.dart';
import '../core/models/payment.dart';
import '../core/models/policy.dart';
import '../core/models/claim.dart';
import '../core/models/quotation.dart';

/// Single in-memory dataset used by every mock repository so numbers stay
/// consistent across screens (e.g. the Home summary matches My Policies).
/// Swap the repositories in `lib/data/repositories/` for real API calls
/// later — this file goes away without touching any screen.
class MockData {
  MockData._();

  static const demoUnclaimedPolicyNumber = 'TG-OFFLINE-7734';
  static const demoUnclaimedDob = '1990-05-12';

  static final currentUser = AppUser(
    id: 'u1',
    fullName: 'Jordan Lee',
    email: 'jordan.lee@email.com',
    phone: '+1 555-0142',
    kycVerified: true,
    memberSince: DateTime(2022, 1, 3),
  );

  static final List<InsurancePackage> packages = [
    const InsurancePackage(
      id: 'pkg_health_basic',
      category: InsuranceCategoryType.health,
      name: 'Health Shield Basic',
      tagline: 'Everyday medical cover, no surprises',
      description: 'Solid coverage for everyday health needs — outpatient visits, emergencies, and an annual checkup, all with a straightforward claims process.',
      monthlyPrice: 45,
      coverageAmount: 50000,
      durationMonths: 12,
      benefits: [
        'Outpatient care',
        'Emergency room visits',
        'Annual health checkup',
        'Prescription discount',
      ],
    ),
    const InsurancePackage(
      id: 'pkg_health_premium',
      category: InsuranceCategoryType.health,
      name: 'Health Shield Premium',
      tagline: 'Complete care for you and your family',
      description: 'Our most complete health plan — specialist visits, dental and vision, and maternity care, with no waiting period so cover starts the day you buy it.',
      monthlyPrice: 89,
      coverageAmount: 150000,
      durationMonths: 12,
      benefits: [
        'Everything in Basic',
        'Specialist consultations',
        'Dental & vision',
        'Maternity care',
        'No waiting period',
      ],
      isFeatured: true,
      reviewCount: 482,
    ),
    const InsurancePackage(
      id: 'pkg_life_term',
      category: InsuranceCategoryType.life,
      name: 'Life Secure Term 20',
      tagline: 'Affordable protection for your family\'s future',
      description: 'A 20-year term life policy that pays out for your loved ones when it matters most, with an accelerated payout if you\'re diagnosed with a terminal illness.',
      monthlyPrice: 32,
      coverageAmount: 250000,
      durationMonths: 240,
      benefits: [
        '20-year term',
        'Accidental death benefit',
        'Terminal illness payout',
        'No medical exam under 40',
      ],
    ),
    const InsurancePackage(
      id: 'pkg_life_whole',
      category: InsuranceCategoryType.life,
      name: 'Life Secure Whole Life',
      tagline: 'Lifetime cover that builds cash value',
      description: 'Coverage that never expires, with a savings component that grows over time and can be borrowed against when you need it.',
      monthlyPrice: 68,
      coverageAmount: 500000,
      durationMonths: 0,
      benefits: [
        'Lifetime coverage',
        'Cash value growth',
        'Flexible premiums',
        'Loan against policy',
      ],
      reviewCount: 201,
    ),
    const InsurancePackage(
      id: 'pkg_auto_essential',
      category: InsuranceCategoryType.vehicle,
      name: 'AutoGuard Essential',
      tagline: 'Legally covered, budget-friendly',
      description: 'Meets the essentials — third-party liability, roadside help, and windshield cover for daily drivers.',
      monthlyPrice: 38,
      coverageAmount: 30000,
      durationMonths: 12,
      benefits: [
        'Third-party liability',
        '24/7 roadside assistance',
        'Windshield cover',
      ],
    ),
    const InsurancePackage(
      id: 'pkg_auto_comprehensive',
      category: InsuranceCategoryType.vehicle,
      name: 'AutoGuard Comprehensive',
      tagline: 'Full protection, zero depreciation',
      description: 'Own-damage and third-party cover in one plan, with zero depreciation on claims and engine protection for total peace of mind.',
      monthlyPrice: 72,
      coverageAmount: 80000,
      durationMonths: 12,
      benefits: [
        'Everything in Essential',
        'Own-damage cover',
        'Zero depreciation',
        'Engine protection',
        '24/7 claim support',
      ],
      isFeatured: true,
      reviewCount: 356,
    ),
    const InsurancePackage(
      id: 'pkg_home_renters',
      category: InsuranceCategoryType.home,
      name: 'HomeSafe Renters',
      tagline: 'Protect what\'s yours, wherever you rent',
      description: 'Covers your belongings against fire and theft, plus temporary relocation if your rental becomes unlivable.',
      monthlyPrice: 18,
      coverageAmount: 25000,
      durationMonths: 12,
      benefits: ['Personal belongings', 'Fire & theft', 'Temporary relocation'],
    ),
    const InsurancePackage(
      id: 'pkg_home_owners',
      category: InsuranceCategoryType.home,
      name: 'HomeSafe Owners',
      tagline: 'Complete cover for the place you own',
      description: 'Structure and belongings, natural disaster cover, and liability protection for homeowners.',
      monthlyPrice: 55,
      coverageAmount: 200000,
      durationMonths: 12,
      benefits: [
        'Structure & belongings',
        'Natural disaster cover',
        'Liability protection',
        'Home office equipment',
      ],
      reviewCount: 164,
    ),
    const InsurancePackage(
      id: 'pkg_travel_single',
      category: InsuranceCategoryType.travel,
      name: 'TravelEase Single Trip',
      tagline: 'One trip, fully covered',
      description: 'Trip cancellation, lost baggage, and emergency medical cover abroad for a single upcoming trip.',
      monthlyPrice: 15,
      coverageAmount: 20000,
      durationMonths: 1,
      benefits: [
        'Trip cancellation',
        'Lost baggage',
        'Medical emergency abroad',
      ],
    ),
    const InsurancePackage(
      id: 'pkg_travel_annual',
      category: InsuranceCategoryType.travel,
      name: 'TravelEase Annual Multi-Trip',
      tagline: 'Unlimited trips, one annual plan',
      description: 'Unlimited trips under 30 days each, with medical evacuation and adventure sports cover included.',
      monthlyPrice: 25,
      coverageAmount: 40000,
      durationMonths: 12,
      benefits: [
        'Unlimited trips under 30 days',
        'Medical evacuation',
        'Flight delay compensation',
        'Adventure sports cover',
      ],
      isFeatured: true,
      reviewCount: 98,
    ),
  ];

  static InsurancePackage packageById(String id) =>
      packages.firstWhere((p) => p.id == id);

  static List<PackagePlanOption> planOptionsFor(InsurancePackage package) {
    final monthly = package.monthlyPrice;
    return [
      PackagePlanOption(label: 'Monthly', months: 1, totalPrice: monthly),
      PackagePlanOption(
        label: '6 months',
        months: 6,
        totalPrice: monthly * 6 * 0.95,
      ),
      PackagePlanOption(
        label: '12 months',
        months: 12,
        totalPrice: monthly * 12 * 0.85,
        badge: 'Save 15%',
      ),
    ];
  }

  static const List<PackageAddOn> addOns = [
    PackageAddOn(
      id: 'addon_priority',
      name: 'Priority claims',
      description: 'Claims reviewed within 24 hours',
      price: 4.5,
    ),
    PackageAddOn(
      id: 'addon_family',
      name: 'Add family member',
      description: 'Extend this plan to one dependent',
      price: 12,
    ),
  ];

  static final DateTime _now = DateTime.now();

  static final List<Policy> policies = [
    Policy(
      id: 'pol_1',
      policyNumber: 'POL-2024-0091',
      package: packageById('pkg_health_premium'),
      status: PolicyStatus.active,
      source: PolicySource.appPurchase,
      startDate: DateTime(_now.year, 3, 1),
      endDate: DateTime(_now.year + 1, 3, 1),
      totalPremium: 89 * 12,
      amountPaid: 89 * 7,
      nextPaymentDate: _now.add(const Duration(days: 12)),
      nextPaymentAmount: 89,
    ),
    Policy(
      id: 'pol_2',
      policyNumber: 'POL-2024-0142',
      package: packageById('pkg_auto_comprehensive'),
      status: PolicyStatus.active,
      source: PolicySource.linkedExisting,
      startDate: DateTime(_now.year, 1, 15),
      endDate: DateTime(_now.year + 1, 1, 15),
      totalPremium: 72 * 12,
      amountPaid: 72 * 10,
      nextPaymentDate: _now.subtract(const Duration(days: 9)),
      nextPaymentAmount: 72,
    ),
    Policy(
      id: 'pol_3',
      policyNumber: 'POL-2023-0087',
      package: packageById('pkg_life_term'),
      status: PolicyStatus.active,
      source: PolicySource.appPurchase,
      startDate: DateTime(2023, 6, 1),
      endDate: DateTime(2043, 6, 1),
      totalPremium: 32 * 240,
      amountPaid: 32 * 16,
      nextPaymentDate: _now.add(const Duration(days: 16)),
      nextPaymentAmount: 32,
    ),
    Policy(
      id: 'pol_4',
      policyNumber: 'POL-2022-0055',
      package: packageById('pkg_home_renters'),
      status: PolicyStatus.expired,
      source: PolicySource.appPurchase,
      startDate: DateTime(2022, 1, 1),
      endDate: DateTime(2023, 1, 1),
      totalPremium: 18 * 12,
      amountPaid: 18 * 12,
    ),
  ];

  static Policy policyById(String id) => policies.firstWhere((p) => p.id == id);

  static final List<Payment> payments = [
    // pol_1 Health Shield — 7 paid months + next pending + one future pending
    Payment(
      id: 'pay_1001',
      policyId: 'pol_1',
      policyName: 'Health Shield Premium',
      invoiceNumber: 'INV-1001',
      amount: 89,
      dueDate: DateTime(_now.year, _now.month - 6, 1),
      paidDate: DateTime(_now.year, _now.month - 6, 1),
      status: PaymentStatus.paid,
      method: PaymentMethod.card,
    ),
    Payment(
      id: 'pay_1002',
      policyId: 'pol_1',
      policyName: 'Health Shield Premium',
      invoiceNumber: 'INV-1002',
      amount: 89,
      dueDate: DateTime(_now.year, _now.month - 5, 1),
      paidDate: DateTime(_now.year, _now.month - 5, 3),
      status: PaymentStatus.paid,
      method: PaymentMethod.card,
    ),
    Payment(
      id: 'pay_1003',
      policyId: 'pol_1',
      policyName: 'Health Shield Premium',
      invoiceNumber: 'INV-1003',
      amount: 89,
      dueDate: DateTime(_now.year, _now.month - 4, 1),
      paidDate: DateTime(_now.year, _now.month - 4, 1),
      status: PaymentStatus.paid,
      method: PaymentMethod.eWallet,
    ),
    Payment(
      id: 'pay_1004',
      policyId: 'pol_1',
      policyName: 'Health Shield Premium',
      invoiceNumber: 'INV-1004',
      amount: 89,
      dueDate: DateTime(_now.year, _now.month - 3, 1),
      paidDate: DateTime(_now.year, _now.month - 3, 2),
      status: PaymentStatus.paid,
      method: PaymentMethod.card,
    ),
    Payment(
      id: 'pay_1005',
      policyId: 'pol_1',
      policyName: 'Health Shield Premium',
      invoiceNumber: 'INV-1005',
      amount: 89,
      dueDate: DateTime(_now.year, _now.month - 2, 1),
      paidDate: DateTime(_now.year, _now.month - 2, 1),
      status: PaymentStatus.paid,
      method: PaymentMethod.card,
    ),
    Payment(
      id: 'pay_1006',
      policyId: 'pol_1',
      policyName: 'Health Shield Premium',
      invoiceNumber: 'INV-1006',
      amount: 89,
      dueDate: DateTime(_now.year, _now.month - 1, 1),
      paidDate: DateTime(_now.year, _now.month - 1, 2),
      status: PaymentStatus.paid,
      method: PaymentMethod.bankTransfer,
    ),
    Payment(
      id: 'pay_1007',
      policyId: 'pol_1',
      policyName: 'Health Shield Premium',
      invoiceNumber: 'INV-1007',
      amount: 89,
      dueDate: DateTime(_now.year, _now.month, 1),
      paidDate: DateTime(_now.year, _now.month, 1),
      status: PaymentStatus.paid,
      method: PaymentMethod.card,
    ),
    Payment(
      id: 'pay_1008',
      policyId: 'pol_1',
      policyName: 'Health Shield Premium',
      invoiceNumber: 'INV-1008',
      amount: 89,
      dueDate: _now.add(const Duration(days: 12)),
      status: PaymentStatus.pending,
    ),
    Payment(
      id: 'pay_1009',
      policyId: 'pol_1',
      policyName: 'Health Shield Premium',
      invoiceNumber: 'INV-1009',
      amount: 89,
      dueDate: _now.add(const Duration(days: 42)),
      status: PaymentStatus.pending,
    ),
    // pol_2 AutoGuard — paid + overdue
    Payment(
      id: 'pay_2001',
      policyId: 'pol_2',
      policyName: 'AutoGuard Comprehensive',
      invoiceNumber: 'INV-2001',
      amount: 72,
      dueDate: DateTime(_now.year, _now.month - 1, 15),
      paidDate: DateTime(_now.year, _now.month - 1, 14),
      status: PaymentStatus.paid,
      method: PaymentMethod.eWallet,
    ),
    Payment(
      id: 'pay_2002',
      policyId: 'pol_2',
      policyName: 'AutoGuard Comprehensive',
      invoiceNumber: 'INV-2002',
      amount: 72,
      dueDate: _now.subtract(const Duration(days: 9)),
      status: PaymentStatus.overdue,
    ),
    Payment(
      id: 'pay_2003',
      policyId: 'pol_2',
      policyName: 'AutoGuard Comprehensive',
      invoiceNumber: 'INV-2003',
      amount: 72,
      dueDate: _now.add(const Duration(days: 21)),
      status: PaymentStatus.pending,
    ),
    // pol_3 Life Secure
    Payment(
      id: 'pay_3001',
      policyId: 'pol_3',
      policyName: 'Life Secure Term 20',
      invoiceNumber: 'INV-3001',
      amount: 32,
      dueDate: DateTime(_now.year, _now.month - 1, 5),
      paidDate: DateTime(_now.year, _now.month - 1, 5),
      status: PaymentStatus.paid,
      method: PaymentMethod.bankTransfer,
    ),
    Payment(
      id: 'pay_3002',
      policyId: 'pol_3',
      policyName: 'Life Secure Term 20',
      invoiceNumber: 'INV-3002',
      amount: 32,
      dueDate: _now.add(const Duration(days: 16)),
      status: PaymentStatus.pending,
    ),
    // pol_4 expired — fully paid
    Payment(
      id: 'pay_4001',
      policyId: 'pol_4',
      policyName: 'HomeSafe Renters',
      invoiceNumber: 'INV-4001',
      amount: 18,
      dueDate: DateTime(2022, 12, 1),
      paidDate: DateTime(2022, 12, 1),
      status: PaymentStatus.paid,
      method: PaymentMethod.card,
    ),
  ];

  static List<Payment> paymentsForPolicy(String policyId) =>
      payments.where((p) => p.policyId == policyId).toList();

  static final List<Quotation> quotations = [
    Quotation(
      id: 'quot_1',
      packageId: 'pkg_health_premium',
      package: packageById('pkg_health_premium'),
      preferredPlanMonths: 12,
      notes: 'Looking for family coverage options.',
      status: QuotationStatus.quoted,
      quotedPremium: 980,
      validUntil: _now.add(const Duration(days: 14)),
      salesNotes: '12-month plan with 8% multi-policy discount applied.',
      createdAt: _now.subtract(const Duration(days: 3)),
    ),
    Quotation(
      id: 'quot_2',
      packageId: 'pkg_auto_comprehensive',
      package: packageById('pkg_auto_comprehensive'),
      preferredPlanMonths: 6,
      notes: 'Need a quote before renewing my current auto policy.',
      status: QuotationStatus.pending,
      createdAt: _now.subtract(const Duration(days: 1)),
    ),
    Quotation(
      id: 'quot_3',
      packageId: 'pkg_travel_single',
      package: packageById('pkg_travel_single'),
      preferredPlanMonths: 1,
      notes: 'Trip to Europe in two months.',
      status: QuotationStatus.expired,
      quotedPremium: 45,
      validUntil: _now.subtract(const Duration(days: 5)),
      salesNotes: 'Single-trip rate for 21 days.',
      createdAt: _now.subtract(const Duration(days: 20)),
    ),
  ];

  static Quotation quotationById(String id) =>
      quotations.firstWhere((q) => q.id == id);

  static final List<Claim> claims = [
    Claim(
      id: 'clm_1',
      claimNumber: 'CLM-2026-1001',
      policyId: 'pol_1',
      policyName: 'Health Shield Premium',
      type: ClaimType.medical,
      status: ClaimStatus.underReview,
      description: 'Emergency clinic visit after a sports injury. Receipts attached offline.',
      amount: 320,
      incidentDate: _now.subtract(const Duration(days: 5)),
      submittedAt: _now.subtract(const Duration(days: 4)),
    ),
    Claim(
      id: 'clm_2',
      claimNumber: 'CLM-2026-1002',
      policyId: 'pol_2',
      policyName: 'AutoGuard Comprehensive',
      type: ClaimType.accident,
      status: ClaimStatus.submitted,
      description:
          'Minor rear-end collision in a parking lot. No injuries reported.',
      amount: 850,
      incidentDate: _now.subtract(const Duration(days: 2)),
      submittedAt: _now.subtract(const Duration(days: 1)),
    ),
    Claim(
      id: 'clm_3',
      claimNumber: 'CLM-2025-0888',
      policyId: 'pol_1',
      policyName: 'Health Shield Premium',
      type: ClaimType.medical,
      status: ClaimStatus.approved,
      description: 'Annual checkup lab panel.',
      amount: 120,
      incidentDate: _now.subtract(const Duration(days: 60)),
      submittedAt: _now.subtract(const Duration(days: 55)),
      reviewNotes: 'Approved. Reimbursement processed within policy limits.',
    ),
  ];

  static Claim claimById(String id) => claims.firstWhere((c) => c.id == id);

  static final List<AppNotification> notifications = [
    AppNotification(
      id: 'n1',
      type: NotificationType.payment,
      title: 'Payment overdue',
      body: 'Your AutoGuard Comprehensive payment of \$72 is 9 days overdue. Pay now to avoid a lapse in cover.',
      createdAt: _now.subtract(const Duration(days: 1)),
    ),
    AppNotification(
      id: 'n2',
      type: NotificationType.policy,
      title: 'Your Home policy has expired',
      body: 'HomeSafe Renters expired. Renew or browse a new home plan to stay protected.',
      createdAt: _now.subtract(const Duration(days: 3)),
    ),
    AppNotification(
      id: 'n3',
      type: NotificationType.payment,
      title: 'Payment received',
      body:
          'We received your \$89 payment for Health Shield Premium. Thank you!',
      createdAt: _now.subtract(const Duration(days: 30)),
      isRead: true,
    ),
    AppNotification(
      id: 'n4',
      type: NotificationType.promo,
      title: 'New: Travel Annual Multi-Trip',
      body: 'Unlimited trips under one annual plan, now 10% off for your first year.',
      createdAt: _now.subtract(const Duration(days: 6)),
      isRead: true,
    ),
    AppNotification(
      id: 'n5',
      type: NotificationType.system,
      title: 'Identity verified',
      body: 'Your KYC verification is complete. You now have full access to claims and support.',
      createdAt: _now.subtract(const Duration(days: 400)),
      isRead: true,
    ),
  ];
}
