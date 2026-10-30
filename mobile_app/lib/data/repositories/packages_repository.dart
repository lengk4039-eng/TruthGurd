import '../../core/models/insurance_category.dart';
import '../../core/models/insurance_package.dart';
import '../mock_data.dart';

abstract class PackagesRepository {
  Future<List<InsurancePackage>> getPackages({
    InsuranceCategoryType? category,
    String? query,
  });
  Future<InsurancePackage> getPackageById(String id);
  Future<List<InsurancePackage>> getFeatured();
}

class MockPackagesRepository implements PackagesRepository {
  @override
  Future<List<InsurancePackage>> getPackages({
    InsuranceCategoryType? category,
    String? query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var results = MockData.packages;
    if (category != null) {
      results = results.where((p) => p.category == category).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      results = results
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.tagline.toLowerCase().contains(q),
          )
          .toList();
    }
    return results;
  }

  @override
  Future<InsurancePackage> getPackageById(String id) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return MockData.packageById(id);
  }

  @override
  Future<List<InsurancePackage>> getFeatured() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.packages.where((p) => p.isFeatured).toList();
  }
}
