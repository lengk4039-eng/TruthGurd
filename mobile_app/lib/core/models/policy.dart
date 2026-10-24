import 'insurance_package.dart';

enum PolicyStatus {
  active,
  pending,
  expired,
  cancelled;

  static PolicyStatus fromJson(String value) => values.byName(value.toLowerCase());
}

extension PolicyStatusX on PolicyStatus {
  String get label {
    switch (this) {
      case PolicyStatus.active:
        return 'Active';
      case PolicyStatus.pending:
        return 'Pending';
      case PolicyStatus.expired:
        return 'Expired';
      case PolicyStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum PolicySource {
  appPurchase,
  linkedExisting;

  static PolicySource fromJson(String value) => switch (value) {
        'APP_PURCHASE' => PolicySource.appPurchase,
        'LINKED_EXISTING' => PolicySource.linkedExisting,
        _ => throw ArgumentError('Unknown PolicySource: $value'),
      };
}

class Policy {
  final String id;
  final String policyNumber;
  final InsurancePackage package;
  final PolicyStatus status;
  final PolicySource source;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPremium;
  final double amountPaid;
  final DateTime? nextPaymentDate;
  final double? nextPaymentAmount;

  const Policy({
    required this.id,
    required this.policyNumber,
    required this.package,
    required this.status,
    required this.source,
    required this.startDate,
    required this.endDate,
    required this.totalPremium,
    required this.amountPaid,
    this.nextPaymentDate,
    this.nextPaymentAmount,
  });

  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      id: json['id'] as String,
      policyNumber: json['policyNumber'] as String,
      package: InsurancePackage.fromJson(json['insurancePackage'] as Map<String, dynamic>),
      status: PolicyStatus.fromJson(json['status'] as String),
      source: PolicySource.fromJson(json['source'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalPremium: (json['totalPremium'] as num).toDouble(),
      amountPaid: (json['amountPaid'] as num).toDouble(),
      nextPaymentDate: json['nextPaymentDate'] != null
          ? DateTime.parse(json['nextPaymentDate'] as String)
          : null,
      nextPaymentAmount: json['nextPaymentAmount'] != null
          ? (json['nextPaymentAmount'] as num).toDouble()
          : null,
    );
  }

  double get paidProgress => totalPremium == 0 ? 0 : (amountPaid / totalPremium).clamp(0, 1);

  Policy copyWith({
    PolicyStatus? status,
    double? amountPaid,
    DateTime? nextPaymentDate,
    double? nextPaymentAmount,
    bool clearNextPayment = false,
  }) {
    return Policy(
      id: id,
      policyNumber: policyNumber,
      package: package,
      status: status ?? this.status,
      source: source,
      startDate: startDate,
      endDate: endDate,
      totalPremium: totalPremium,
      amountPaid: amountPaid ?? this.amountPaid,
      nextPaymentDate: clearNextPayment ? null : (nextPaymentDate ?? this.nextPaymentDate),
      nextPaymentAmount: clearNextPayment ? null : (nextPaymentAmount ?? this.nextPaymentAmount),
    );
  }
}
