import '../../core/models/insurance_package.dart';
import '../../core/models/payment.dart';
import '../../core/models/policy.dart';
import '../../core/network/api_client.dart';
import 'policies_repository.dart';

class DioPoliciesRepository implements PoliciesRepository {
  @override
  Future<List<Policy>> getMyPolicies() {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.get('/policies/me');
      return (response.data as List)
          .map((e) => Policy.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<Policy> getPolicyById(String id) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.get('/policies/$id');
      return Policy.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<Policy> purchasePackage({
    required InsurancePackage package,
    required PackagePlanOption plan,
    required PaymentMethod method,
    List<PackageAddOn> addOns = const [],
    String? quotationId,
  }) {
    return unwrapDioErrors(() async {
      final addOnTotal = addOns.fold<double>(
        0,
        (sum, a) => sum + a.price * plan.months,
      );
      final response = await ApiClient.instance.post(
        '/policies/purchase',
        data: {
          'packageId': package.id,
          'durationMonths': plan.months,
          'paymentMethod': method.toJson(),
          if (addOnTotal > 0 && quotationId == null) 'addOnTotal': addOnTotal,
          if (quotationId != null) 'quotationId': quotationId,
          if (quotationId != null) 'quotedPremium': plan.totalPrice,
        },
      );
      return Policy.fromJson(response.data as Map<String, dynamic>);
    });
  }
}
