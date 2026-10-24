enum PaymentStatus {
  paid,
  pending,
  overdue,
  failed;

  static PaymentStatus fromJson(String value) => values.byName(value.toLowerCase());
  String toJson() => name.toUpperCase();
}

extension PaymentStatusX on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.overdue:
        return 'Overdue';
      case PaymentStatus.failed:
        return 'Failed';
    }
  }
}

enum PaymentMethod {
  card,
  bankTransfer,
  eWallet;

  static PaymentMethod fromJson(String value) => switch (value) {
        'CARD' => PaymentMethod.card,
        'BANK_TRANSFER' => PaymentMethod.bankTransfer,
        'E_WALLET' => PaymentMethod.eWallet,
        _ => throw ArgumentError('Unknown PaymentMethod: $value'),
      };

  String toJson() => switch (this) {
        PaymentMethod.card => 'CARD',
        PaymentMethod.bankTransfer => 'BANK_TRANSFER',
        PaymentMethod.eWallet => 'E_WALLET',
      };
}

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.card:
        return 'Credit / Debit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.eWallet:
        return 'E-Wallet';
    }
  }
}

class Payment {
  final String id;
  final String policyId;
  final String policyName;
  final String invoiceNumber;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final PaymentStatus status;
  final PaymentMethod? method;

  const Payment({
    required this.id,
    required this.policyId,
    required this.policyName,
    required this.invoiceNumber,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.method,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      policyId: json['policyId'] as String,
      policyName: json['policyName'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate'] as String) : null,
      status: PaymentStatus.fromJson(json['status'] as String),
      method: json['method'] != null ? PaymentMethod.fromJson(json['method'] as String) : null,
    );
  }

  Payment copyWith({
    DateTime? paidDate,
    PaymentStatus? status,
    PaymentMethod? method,
  }) {
    return Payment(
      id: id,
      policyId: policyId,
      policyName: policyName,
      invoiceNumber: invoiceNumber,
      amount: amount,
      dueDate: dueDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      method: method ?? this.method,
    );
  }
}
