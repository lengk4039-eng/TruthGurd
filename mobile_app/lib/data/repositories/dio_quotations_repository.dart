import '../../core/models/quotation.dart';
import '../../core/network/api_client.dart';
import 'quotations_repository.dart';

/// Real API implementation — used when [useMockData] is false.
class DioQuotationsRepository implements QuotationsRepository {
  @override
  Future<List<Quotation>> getMyQuotations() {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.get('/quotations/me');
      return (response.data as List)
          .map((e) => Quotation.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<Quotation> getQuotationById(String id) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.get('/quotations/$id');
      return Quotation.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<Quotation> requestQuotation({
    required String packageId,
    required int preferredPlanMonths,
    String notes = '',
  }) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.post(
        '/quotations',
        data: {
          'packageId': packageId,
          'preferredPlanMonths': preferredPlanMonths,
          'notes': notes,
        },
      );
      return Quotation.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<Quotation> declineQuotation(String id) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.post('/quotations/$id/decline');
      return Quotation.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<Quotation> markAccepted({
    required String quotationId,
    required String policyId,
  }) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.post(
        '/quotations/$quotationId/accept',
        data: {'policyId': policyId},
      );
      return Quotation.fromJson(response.data as Map<String, dynamic>);
    });
  }
}
