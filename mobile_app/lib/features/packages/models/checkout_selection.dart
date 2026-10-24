import '../../../core/models/insurance_package.dart';
import '../../../core/models/payment.dart';
import '../../../core/models/policy.dart';
import '../../../core/models/quotation.dart';

class CheckoutSelection {
  final InsurancePackage package;
  final PackagePlanOption plan;
  final List<PackageAddOn> addOns;
  /// When set, this checkout is fulfilling a sales quotation at the quoted price.
  final String? quotationId;

  const CheckoutSelection({
    required this.package,
    required this.plan,
    this.addOns = const [],
    this.quotationId,
  });

  factory CheckoutSelection.fromQuotation(Quotation quotation) {
    final premium = quotation.quotedPremium;
    if (premium == null) {
      throw StateError('Cannot checkout a quotation without a quoted premium.');
    }
    return CheckoutSelection(
      package: quotation.package,
      plan: PackagePlanOption(
        label: '${quotation.preferredPlanMonths}-month quoted plan',
        months: quotation.preferredPlanMonths,
        totalPrice: premium,
        badge: 'Quoted',
      ),
      quotationId: quotation.id,
    );
  }

  bool get isFromQuotation => quotationId != null;

  double get addOnTotal => addOns.fold<double>(0, (sum, a) => sum + a.price * plan.months);

  /// Quoted checkouts use the sales price only (no extra add-ons on this path).
  double get total => isFromQuotation ? plan.totalPrice : plan.totalPrice + addOnTotal;
}

class PurchaseResult {
  final Policy policy;
  final PaymentMethod method;
  final bool fromQuotation;

  const PurchaseResult({
    required this.policy,
    required this.method,
    this.fromQuotation = false,
  });
}
