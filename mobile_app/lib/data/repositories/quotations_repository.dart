import '../../core/errors/app_exception.dart';
import '../../core/models/app_notification.dart';
import '../../core/models/quotation.dart';
import '../mock_data.dart';

abstract class QuotationsRepository {
  Future<List<Quotation>> getMyQuotations();
  Future<Quotation> getQuotationById(String id);
  Future<Quotation> requestQuotation({
    required String packageId,
    required int preferredPlanMonths,
    String notes = '',
  });
  Future<Quotation> declineQuotation(String id);

  /// Marks a quoted quotation as accepted and links the new policy.
  Future<Quotation> markAccepted({required String quotationId, required String policyId});
}

class MockQuotationsRepository implements QuotationsRepository {
  @override
  Future<List<Quotation>> getMyQuotations() async {
    await Future.delayed(const Duration(milliseconds: 450));
    final sorted = [...MockData.quotations]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Future<Quotation> getQuotationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.quotationById(id);
  }

  @override
  Future<Quotation> requestQuotation({
    required String packageId,
    required int preferredPlanMonths,
    String notes = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final package = MockData.packageById(packageId);
    final quote = Quotation(
      id: 'quot_${MockData.quotations.length + 1}_${DateTime.now().millisecondsSinceEpoch}',
      packageId: packageId,
      package: package,
      preferredPlanMonths: preferredPlanMonths,
      notes: notes.trim(),
      status: QuotationStatus.pending,
      createdAt: DateTime.now(),
    );
    MockData.quotations.insert(0, quote);
    MockData.notifications.insert(
      0,
      AppNotification(
        id: 'n_quote_${quote.id}',
        type: NotificationType.system,
        title: 'Quotation submitted',
        body: 'We received your request for ${package.name}. Our team will respond shortly.',
        createdAt: DateTime.now(),
      ),
    );
    return quote;
  }

  @override
  Future<Quotation> declineQuotation(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = MockData.quotations.indexWhere((q) => q.id == id);
    if (index == -1) throw const AppException('Quotation not found.');
    final current = MockData.quotations[index];
    if (current.status != QuotationStatus.quoted && current.status != QuotationStatus.pending) {
      throw const AppException('This quotation can no longer be declined.');
    }
    final updated = current.copyWith(status: QuotationStatus.rejected);
    MockData.quotations[index] = updated;
    return updated;
  }

  @override
  Future<Quotation> markAccepted({required String quotationId, required String policyId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = MockData.quotations.indexWhere((q) => q.id == quotationId);
    if (index == -1) throw const AppException('Quotation not found.');
    final current = MockData.quotations[index];
    if (!current.canAccept) {
      throw const AppException('This quotation cannot be accepted. It may have expired.');
    }
    final updated = current.copyWith(status: QuotationStatus.accepted, policyId: policyId);
    MockData.quotations[index] = updated;
    MockData.notifications.insert(
      0,
      AppNotification(
        id: 'n_quote_accept_$quotationId',
        type: NotificationType.policy,
        title: 'Quote accepted',
        body: 'Your ${current.package.name} quotation is now an active policy.',
        createdAt: DateTime.now(),
      ),
    );
    return updated;
  }
}
