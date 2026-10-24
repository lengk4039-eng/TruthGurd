import '../../core/models/payment.dart';
import '../mock_data.dart';

abstract class PaymentsRepository {
  Future<List<Payment>> getMyPayments();
  Future<List<Payment>> getPaymentsForPolicy(String policyId);
  Future<Payment> getPaymentById(String id);
  Future<Payment> payNow(String paymentId, PaymentMethod method);
}

class MockPaymentsRepository implements PaymentsRepository {
  @override
  Future<List<Payment>> getMyPayments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final sorted = [...MockData.payments]..sort((a, b) => b.dueDate.compareTo(a.dueDate));
    return sorted;
  }

  @override
  Future<List<Payment>> getPaymentsForPolicy(String policyId) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return MockData.paymentsForPolicy(policyId);
  }

  @override
  Future<Payment> getPaymentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return MockData.payments.firstWhere((p) => p.id == id);
  }

  @override
  Future<Payment> payNow(String paymentId, PaymentMethod method) async {
    await Future.delayed(const Duration(milliseconds: 1100));
    final index = MockData.payments.indexWhere((p) => p.id == paymentId);
    if (index == -1) throw StateError('Payment not found');
    final updated = MockData.payments[index].copyWith(
      status: PaymentStatus.paid,
      paidDate: DateTime.now(),
      method: method,
    );
    MockData.payments[index] = updated;

    final policyIndex = MockData.policies.indexWhere((p) => p.id == updated.policyId);
    if (policyIndex != -1) {
      final policy = MockData.policies[policyIndex];
      MockData.policies[policyIndex] = policy.copyWith(amountPaid: policy.amountPaid + updated.amount, clearNextPayment: true);
    }
    return updated;
  }
}
