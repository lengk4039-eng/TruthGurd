import 'insurance_package.dart';

enum QuotationStatus {
  pending,
  quoted,
  accepted,
  rejected,
  expired;

  static QuotationStatus fromJson(String value) => values.byName(value.toLowerCase());
  String toJson() => name.toUpperCase();
}

extension QuotationStatusX on QuotationStatus {
  String get label {
    switch (this) {
      case QuotationStatus.pending:
        return 'Pending';
      case QuotationStatus.quoted:
        return 'Quoted';
      case QuotationStatus.accepted:
        return 'Accepted';
      case QuotationStatus.rejected:
        return 'Rejected';
      case QuotationStatus.expired:
        return 'Expired';
    }
  }

  String get description {
    switch (this) {
      case QuotationStatus.pending:
        return 'Waiting for our sales team to review';
      case QuotationStatus.quoted:
        return 'Price is ready — accept before it expires';
      case QuotationStatus.accepted:
        return 'You accepted this quote and purchased cover';
      case QuotationStatus.rejected:
        return 'This quote was declined';
      case QuotationStatus.expired:
        return 'This quote is no longer valid';
    }
  }
}

class Quotation {
  final String id;
  final String packageId;
  final InsurancePackage package;
  final int preferredPlanMonths;
  final String notes;
  final QuotationStatus status;
  final double? quotedPremium;
  final DateTime? validUntil;
  final String? salesNotes;
  final DateTime createdAt;
  final String? policyId;

  const Quotation({
    required this.id,
    required this.packageId,
    required this.package,
    required this.preferredPlanMonths,
    this.notes = '',
    required this.status,
    this.quotedPremium,
    this.validUntil,
    this.salesNotes,
    required this.createdAt,
    this.policyId,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      id: json['id'] as String,
      packageId: json['packageId'] as String,
      package: InsurancePackage.fromJson(json['insurancePackage'] as Map<String, dynamic>),
      preferredPlanMonths: json['preferredPlanMonths'] as int,
      notes: json['notes'] as String? ?? '',
      status: QuotationStatus.fromJson(json['status'] as String),
      quotedPremium: json['quotedPremium'] != null ? (json['quotedPremium'] as num).toDouble() : null,
      validUntil: json['validUntil'] != null ? DateTime.parse(json['validUntil'] as String) : null,
      salesNotes: json['salesNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      policyId: json['policyId'] as String?,
    );
  }

  Quotation copyWith({
    QuotationStatus? status,
    double? quotedPremium,
    DateTime? validUntil,
    String? salesNotes,
    String? policyId,
  }) {
    return Quotation(
      id: id,
      packageId: packageId,
      package: package,
      preferredPlanMonths: preferredPlanMonths,
      notes: notes,
      status: status ?? this.status,
      quotedPremium: quotedPremium ?? this.quotedPremium,
      validUntil: validUntil ?? this.validUntil,
      salesNotes: salesNotes ?? this.salesNotes,
      createdAt: createdAt,
      policyId: policyId ?? this.policyId,
    );
  }

  bool get canAccept {
    if (status != QuotationStatus.quoted) return false;
    if (validUntil != null && validUntil!.isBefore(DateTime.now())) return false;
    return quotedPremium != null;
  }

  bool get isOpen => status == QuotationStatus.pending || status == QuotationStatus.quoted;
}
