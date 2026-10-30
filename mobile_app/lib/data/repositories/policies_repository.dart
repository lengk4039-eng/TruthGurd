import '../../core/models/app_notification.dart';
import '../../core/models/insurance_package.dart';
import '../../core/models/payment.dart';
import '../../core/models/policy.dart';
import '../mock_data.dart';

abstract class PoliciesRepository {
  Future<List<Policy>> getMyPolicies();
  Future<Policy> getPolicyById(String id);

  /// Buys (or renews) a package for the current user and returns the new policy.
  Future<Policy> purchasePackage({
    required InsurancePackage package,
    required PackagePlanOption plan,
    required PaymentMethod method,
    List<PackageAddOn> addOns = const [],
    String? quotationId,
  });
}

class MockPoliciesRepository implements PoliciesRepository {
  @override
  Future<List<Policy>> getMyPolicies() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(MockData.policies);
  }

  @override
  Future<Policy> getPolicyById(String id) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return MockData.policyById(id);
  }

  @override
  Future<Policy> purchasePackage({
    required InsurancePackage package,
    required PackagePlanOption plan,
    required PaymentMethod method,
    List<PackageAddOn> addOns = const [],
    String? quotationId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final addOnTotal = addOns.fold<double>(
      0,
      (sum, a) => sum + a.price * plan.months,
    );
    final total = quotationId != null
        ? plan.totalPrice
        : plan.totalPrice + addOnTotal;
    final now = DateTime.now();
    final policy = Policy(
      id: 'pol_${MockData.policies.length + 1}_${now.millisecondsSinceEpoch}',
      policyNumber:
          'POL-${now.year}-${(1000 + MockData.policies.length).toString().padLeft(4, '0')}',
      package: package,
      status: PolicyStatus.active,
      source: PolicySource.appPurchase,
      startDate: now,
      endDate: DateTime(now.year, now.month + plan.months, now.day),
      totalPremium: total,
      amountPaid: total,
      nextPaymentDate: null,
      nextPaymentAmount: null,
    );
    MockData.policies.insert(0, policy);

    final payment = Payment(
      id: 'pay_${MockData.payments.length + 1}_${now.millisecondsSinceEpoch}',
      policyId: policy.id,
      policyName: package.name,
      invoiceNumber: 'INV-${2000 + MockData.payments.length}',
      amount: total,
      dueDate: now,
      paidDate: now,
      status: PaymentStatus.paid,
      method: method,
    );
    MockData.payments.insert(0, payment);

    MockData.notifications.insert(
      0,
      AppNotification(
        id: 'n_purchase_${policy.id}',
        type: NotificationType.policy,
        title: quotationId != null
            ? 'Quote converted to policy'
            : 'New policy active',
        body: '${package.name} is now active. Policy ${policy.policyNumber}.',
        createdAt: now,
      ),
    );

    return policy;
  }
}
