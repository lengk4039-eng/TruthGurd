import '../../core/models/payment.dart';
import '../../core/network/api_client.dart';
import 'payments_repository.dart';

class DioPaymentsRepository implements PaymentsRepository {
  @override
  Future<List<Payment>> getMyPayments() {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.get('/payments/me');
      return (response.data as List).map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  @override
  Future<List<Payment>> getPaymentsForPolicy(String policyId) async {
    final payments = await getMyPayments();
    return payments.where((p) => p.policyId == policyId).toList();
  }

  @override
  Future<Payment> getPaymentById(String id) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.get('/payments/$id');
      return Payment.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<Payment> payNow(String paymentId, PaymentMethod method) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.post('/payments/$paymentId/pay', data: {'method': method.toJson()});
      return Payment.fromJson(response.data as Map<String, dynamic>);
    });
  }
}
