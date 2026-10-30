import '../../core/models/claim.dart';
import '../../core/models/claim_eligibility.dart';
import '../../core/network/api_client.dart';
import 'claims_repository.dart';

/// Real API implementation — used when [useMockData] is false.
class DioClaimsRepository implements ClaimsRepository {
  @override
  Future<List<Claim>> getMyClaims() {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.get('/claims/me');
      return (response.data as List)
          .map((e) => Claim.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<Claim> getClaimById(String id) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.get('/claims/$id');
      return Claim.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<List<Claim>> getClaimsForPolicy(String policyId) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.get('/claims/policy/$policyId');
      return (response.data as List)
          .map((e) => Claim.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<ClaimEligibility> getEligibility(String policyId) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.get(
        '/claims/eligibility/$policyId',
      );
      return ClaimEligibility.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<Claim> submitClaim({
    required String policyId,
    required ClaimType type,
    required String description,
    required double amount,
    required DateTime incidentDate,
  }) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.post(
        '/claims',
        data: {
          'policyId': policyId,
          'type': type.toJson(),
          'description': description,
          'amount': amount,
          'incidentDate': incidentDate.toIso8601String().split('T').first,
        },
      );
      return Claim.fromJson(response.data as Map<String, dynamic>);
    });
  }
}
