import 'insurance_category.dart';

class InsurancePackage {
  final String id;
  final InsuranceCategoryType category;
  final String name;
  final String tagline;
  final String description;
  final double monthlyPrice;
  final double coverageAmount;
  final int durationMonths;
  final List<String> benefits;
  final bool isFeatured;
  final double rating;
  final int reviewCount;
  final int waitingPeriodDays;
  final int claimWindowDays;
  final String claimPolicy;
  final List<String> claimDocuments;
  final List<String> exclusions;
  final String legalTerms;

  const InsurancePackage({
    required this.id,
    required this.category,
    required this.name,
    required this.tagline,
    required this.description,
    required this.monthlyPrice,
    required this.coverageAmount,
    required this.durationMonths,
    required this.benefits,
    this.isFeatured = false,
    this.rating = 4.7,
    this.reviewCount = 0,
    this.waitingPeriodDays = 30,
    this.claimWindowDays = 90,
    this.claimPolicy = '',
    this.claimDocuments = const [],
    this.exclusions = const [],
    this.legalTerms = '',
  });

  factory InsurancePackage.fromJson(Map<String, dynamic> json) {
    return InsurancePackage(
      id: json['id'] as String,
      category: InsuranceCategoryType.fromJson(json['category'] as String),
      name: json['name'] as String,
      tagline: json['tagline'] as String,
      description: json['description'] as String,
      monthlyPrice: (json['monthlyPrice'] as num).toDouble(),
      coverageAmount: (json['coverageAmount'] as num).toDouble(),
      durationMonths: json['durationMonths'] as int,
      benefits: (json['benefits'] as List).cast<String>(),
      isFeatured: json['featured'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.7,
      reviewCount: json['reviewCount'] as int? ?? 0,
      waitingPeriodDays: (json['waitingPeriodDays'] as num?)?.toInt() ?? 30,
      claimWindowDays: (json['claimWindowDays'] as num?)?.toInt() ?? 90,
      claimPolicy: json['claimPolicy'] as String? ?? '',
      claimDocuments:
          (json['claimDocuments'] as List?)?.cast<String>() ?? const [],
      exclusions: (json['exclusions'] as List?)?.cast<String>() ?? const [],
      legalTerms: json['legalTerms'] as String? ?? '',
    );
  }
}

/// One selectable duration/price tier shown on the checkout screen.
class PackagePlanOption {
  final String label;
  final int months;
  final double totalPrice;
  final String? badge;

  const PackagePlanOption({
    required this.label,
    required this.months,
    required this.totalPrice,
    this.badge,
  });
}

class PackageAddOn {
  final String id;
  final String name;
  final String description;
  final double price;

  const PackageAddOn({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });
}
