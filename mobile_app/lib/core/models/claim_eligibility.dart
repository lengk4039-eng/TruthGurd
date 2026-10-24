/// Server-side pre-flight result for filing a claim on a policy.
///
/// [eligible] is false for hard blockers (inactive policy, unpaid premium,
/// overdue installment). [withinWaitingPeriod] is advisory: accident claims can
/// still be filed before the waiting period ends.
class ClaimEligibility {
  final String policyId;
  final bool eligible;
  final String code;
  final String title;
  final String message;
  final bool withinWaitingPeriod;
  final DateTime? waitingPeriodEndsAt;
  final String? overduePaymentId;
  final double? overdueAmount;
  final DateTime? overdueDueDate;
  final int waitingPeriodDays;
  final int claimWindowDays;

  const ClaimEligibility({
    required this.policyId,
    required this.eligible,
    required this.code,
    required this.title,
    required this.message,
    required this.withinWaitingPeriod,
    this.waitingPeriodEndsAt,
    this.overduePaymentId,
    this.overdueAmount,
    this.overdueDueDate,
    this.waitingPeriodDays = 30,
    this.claimWindowDays = 90,
  });

  factory ClaimEligibility.fromJson(Map<String, dynamic> json) {
    return ClaimEligibility(
      policyId: json['policyId'] as String,
      eligible: json['eligible'] as bool? ?? false,
      code: json['code'] as String? ?? 'OK',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      withinWaitingPeriod: json['withinWaitingPeriod'] as bool? ?? false,
      waitingPeriodEndsAt: _tryDate(json['waitingPeriodEndsAt']),
      overduePaymentId: json['overduePaymentId'] as String?,
      overdueAmount: (json['overdueAmount'] as num?)?.toDouble(),
      overdueDueDate: _tryDate(json['overdueDueDate']),
      waitingPeriodDays: (json['waitingPeriodDays'] as num?)?.toInt() ?? 30,
      claimWindowDays: (json['claimWindowDays'] as num?)?.toInt() ?? 90,
    );
  }

  bool get canPayOverdue => !eligible && overduePaymentId != null;

  static DateTime? _tryDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
