enum ClaimType {
  medical,
  accident,
  property,
  travel,
  other;

  static ClaimType fromJson(String value) => values.byName(value.toLowerCase());
  String toJson() => name.toUpperCase();
}

extension ClaimTypeX on ClaimType {
  String get label {
    switch (this) {
      case ClaimType.medical:
        return 'Medical';
      case ClaimType.accident:
        return 'Accident';
      case ClaimType.property:
        return 'Property';
      case ClaimType.travel:
        return 'Travel';
      case ClaimType.other:
        return 'Other';
    }
  }
}

enum ClaimStatus {
  submitted,
  underReview,
  approved,
  rejected;

  static ClaimStatus fromJson(String value) {
    final normalized = value.toLowerCase().replaceAll('_', '');
    return values.firstWhere(
      (status) => status.name.toLowerCase() == normalized,
    );
  }

  String toJson() {
    switch (this) {
      case ClaimStatus.submitted:
        return 'SUBMITTED';
      case ClaimStatus.underReview:
        return 'UNDER_REVIEW';
      case ClaimStatus.approved:
        return 'APPROVED';
      case ClaimStatus.rejected:
        return 'REJECTED';
    }
  }
}

extension ClaimStatusX on ClaimStatus {
  String get label {
    switch (this) {
      case ClaimStatus.submitted:
        return 'Submitted';
      case ClaimStatus.underReview:
        return 'Under review';
      case ClaimStatus.approved:
        return 'Approved';
      case ClaimStatus.rejected:
        return 'Rejected';
    }
  }
}

class Claim {
  final String id;
  final String claimNumber;
  final String policyId;
  final String? policyNumber;
  final String policyName;
  final ClaimType type;
  final ClaimStatus status;
  final String description;
  final double amount;
  final DateTime incidentDate;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final DateTime? updatedAt;
  final String? reviewNotes;
  final String? photoUrl;

  const Claim({
    required this.id,
    required this.claimNumber,
    required this.policyId,
    this.policyNumber,
    required this.policyName,
    required this.type,
    required this.status,
    required this.description,
    required this.amount,
    required this.incidentDate,
    required this.submittedAt,
    this.reviewedAt,
    this.updatedAt,
    this.reviewNotes,
    this.photoUrl,
  });

  bool get hasDecision =>
      status == ClaimStatus.approved || status == ClaimStatus.rejected;

  /// Customer-facing guidance shown after every review step.
  String get nextStep {
    switch (status) {
      case ClaimStatus.submitted:
        return 'Your claim is queued for review. Our claims team normally starts the review within 2-3 business days.';
      case ClaimStatus.underReview:
        return 'Our claims team is reviewing your file. Most reviews finish within 2-3 business days, and we will ask here if any document is missing.';
      case ClaimStatus.approved:
        return 'Your claim has been approved. Our payments team will confirm your payout details and transfer the approved amount within 5 business days.';
      case ClaimStatus.rejected:
        return 'The claim was rejected. Read the decision note below. If you disagree, you can appeal within 30 days by contacting TrustGuard support and quoting this claim number.';
    }
  }

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id'] as String,
      claimNumber: json['claimNumber'] as String,
      policyId: json['policyId'] as String,
      policyNumber: json['policyNumber'] as String?,
      policyName: json['policyName'] as String,
      type: ClaimType.fromJson(json['type'] as String),
      status: ClaimStatus.fromJson(json['status'] as String),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      incidentDate: DateTime.parse(json['incidentDate'] as String),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      reviewedAt: _tryDate(json['reviewedAt']),
      updatedAt: _tryDate(json['updatedAt']),
      reviewNotes: json['reviewNotes'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  static DateTime? _tryDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
