import '../../../core/models/payment.dart';

class InstallmentPaymentResult {
  final Payment payment;
  final PaymentMethod method;
  final String instrumentLabel;
  final String reference;
  final DateTime paidAt;

  const InstallmentPaymentResult({
    required this.payment,
    required this.method,
    required this.instrumentLabel,
    required this.reference,
    required this.paidAt,
  });
}
