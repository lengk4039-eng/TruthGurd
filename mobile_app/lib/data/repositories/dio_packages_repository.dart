import '../../core/models/insurance_category.dart';
import '../../core/models/insurance_package.dart';
import '../../core/network/api_client.dart';
import 'packages_repository.dart';

class DioPackagesRepository implements PackagesRepository {
  @override
  Future<List<InsurancePackage>> getPackages({
    InsuranceCategoryType? category,
    String? query,
  }) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.get(
        '/packages',
        queryParameters: {if (category != null) 'category': category.toJson()},
      );
      var packages = (response.data as List)
          .map((e) => InsurancePackage.fromJson(e as Map<String, dynamic>))
          .toList();
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        packages = packages
            .where(
              (p) =>
                  p.name.toLowerCase().contains(q) ||
                  p.tagline.toLowerCase().contains(q),
            )
            .toList();
      }
      return packages;
    });
  }

  @override
  Future<InsurancePackage> getPackageById(String id) {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.get('/packages/$id');
      return InsurancePackage.fromJson(response.data as Map<String, dynamic>);
    });
  }

  @override
  Future<List<InsurancePackage>> getFeatured() {
    return unwrapDioErrors(() async {
      final response = await ApiClient.instance.get('/packages/featured');
      return (response.data as List)
          .map((e) => InsurancePackage.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}
