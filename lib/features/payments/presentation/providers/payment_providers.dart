import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_helper.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../data/datasources/payment_hive_data_source.dart';
import '../../data/datasources/payment_local_data_source.dart';
import '../../data/models/payment_history_model.dart';
import '../../data/models/payment_model.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/repositories/payment_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dependency Injection
// ─────────────────────────────────────────────────────────────────────────────

final paymentDataSourceProvider = Provider<PaymentLocalDataSource>((ref) {
  if (kIsWeb) return PaymentHiveDataSourceImpl();
  return PaymentLocalDataSourceImpl(DatabaseHelper.instance);
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final ds = ref.watch(paymentDataSourceProvider);
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  return PaymentRepositoryImpl(ds, expenseRepo);
});

// ─────────────────────────────────────────────────────────────────────────────
// State Management (CRUD Notifier)
// ─────────────────────────────────────────────────────────────────────────────

class PaymentsNotifier extends AsyncNotifier<List<PaymentModel>> {
  @override
  FutureOr<List<PaymentModel>> build() => _load();

  Future<List<PaymentModel>> _load() {
    return ref.read(paymentRepositoryProvider).getAllPayments();
  }

  Future<void> addPayment(PaymentModel payment) async {
    await ref.read(paymentRepositoryProvider).addPayment(payment);
    ref.invalidateSelf();
    // Invalidate expenses if needed
    if (payment.paymentType == PaymentType.expense) {
      ref.invalidate(expensesNotifierProvider);
    }
  }

  Future<void> updatePayment(PaymentModel payment) async {
    await ref.read(paymentRepositoryProvider).updatePayment(payment);
    ref.invalidateSelf();
    if (payment.paymentType == PaymentType.expense) {
      ref.invalidate(expensesNotifierProvider);
    }
  }

  Future<void> deletePayment(String id, PaymentType type) async {
    await ref.read(paymentRepositoryProvider).deletePayment(id);
    ref.invalidateSelf();
    if (type == PaymentType.expense) {
      ref.invalidate(expensesNotifierProvider);
    }
  }

  Future<void> addHistory(PaymentHistoryModel history, PaymentType parentType) async {
    await ref.read(paymentRepositoryProvider).addPaymentHistory(history);
    ref.invalidateSelf();
    ref.invalidate(paymentHistoryProvider(history.paymentId));
    if (parentType == PaymentType.expense) {
      ref.invalidate(expensesNotifierProvider);
    }
  }

  Future<void> updateHistory(PaymentHistoryModel history, PaymentType parentType) async {
    await ref.read(paymentRepositoryProvider).updatePaymentHistory(history);
    ref.invalidateSelf();
    ref.invalidate(paymentHistoryProvider(history.paymentId));
    if (parentType == PaymentType.expense) {
      ref.invalidate(expensesNotifierProvider);
    }
  }

  Future<void> deleteHistory(PaymentHistoryModel history, PaymentType parentType) async {
    await ref.read(paymentRepositoryProvider).deletePaymentHistory(history.id);
    // Since repository only deletes history, we need to trigger state recalculation:
    // Wait, in my repository, I didn't add the `recalculatePaymentState` inside `deletePaymentHistory(id)`.
    // I added `deleteHistoryRecord(history)` that handles it. So I should cast repo and call it.
    final repo = ref.read(paymentRepositoryProvider) as PaymentRepositoryImpl;
    await repo.deleteHistoryRecord(history);
    
    ref.invalidateSelf();
    ref.invalidate(paymentHistoryProvider(history.paymentId));
    if (parentType == PaymentType.expense) {
      ref.invalidate(expensesNotifierProvider);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }
}

final paymentsNotifierProvider =
    AsyncNotifierProvider<PaymentsNotifier, List<PaymentModel>>(
  PaymentsNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Family Providers
// ─────────────────────────────────────────────────────────────────────────────

final paymentHistoryProvider =
    FutureProvider.family<List<PaymentHistoryModel>, String>((ref, paymentId) async {
  return ref.read(paymentRepositoryProvider).getPaymentHistory(paymentId);
});

final paymentsByProjectProvider =
    FutureProvider.family<List<PaymentModel>, String>((ref, projectId) async {
  final cached = ref.watch(paymentsNotifierProvider).value;
  if (cached != null) {
    return cached.where((p) => p.projectId == projectId).toList();
  }
  return ref.read(paymentRepositoryProvider).getPaymentsByProjectId(projectId);
});

final paymentsByPayeeProvider =
    FutureProvider.family<List<PaymentModel>, String>((ref, payeeId) async {
  final cached = ref.watch(paymentsNotifierProvider).value;
  if (cached != null) {
    return cached.where((p) => p.payeeId == payeeId).toList();
  }
  return ref.read(paymentRepositoryProvider).getPaymentsByPayeeId(payeeId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Filters and Sort State
// ─────────────────────────────────────────────────────────────────────────────

class PaymentSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String v) => state = v;
}
final paymentSearchQueryProvider =
    NotifierProvider<PaymentSearchQueryNotifier, String>(PaymentSearchQueryNotifier.new);

class PaymentStatusFilterNotifier extends Notifier<PaymentStatus?> {
  @override
  PaymentStatus? build() => null;
  void update(PaymentStatus? v) => state = v;
}
final paymentStatusFilterProvider =
    NotifierProvider<PaymentStatusFilterNotifier, PaymentStatus?>(PaymentStatusFilterNotifier.new);

class PaymentTypeFilterNotifier extends Notifier<PaymentType?> {
  @override
  PaymentType? build() => null;
  void update(PaymentType? v) => state = v;
}
final paymentTypeFilterProvider =
    NotifierProvider<PaymentTypeFilterNotifier, PaymentType?>(PaymentTypeFilterNotifier.new);

enum PaymentSortOption { newestFirst, oldestFirst, amountHighToLow, amountLowToHigh }

class PaymentSortOptionNotifier extends Notifier<PaymentSortOption> {
  @override
  PaymentSortOption build() => PaymentSortOption.newestFirst;
  void update(PaymentSortOption v) => state = v;
}
final paymentSortOptionProvider =
    NotifierProvider<PaymentSortOptionNotifier, PaymentSortOption>(PaymentSortOptionNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// Filtered & Sorted Computed Provider
// ─────────────────────────────────────────────────────────────────────────────

final filteredPaymentsProvider = Provider<List<PaymentModel>>((ref) {
  final all = ref.watch(paymentsNotifierProvider).value ?? [];
  final query = ref.watch(paymentSearchQueryProvider).toLowerCase();
  final statusFilter = ref.watch(paymentStatusFilterProvider);
  final typeFilter = ref.watch(paymentTypeFilterProvider);
  final sortOption = ref.watch(paymentSortOptionProvider);

  var filtered = all.where((p) {
    if (query.isNotEmpty) {
      final matches = p.paymentNumber.toLowerCase().contains(query) ||
          (p.invoiceNumber?.toLowerCase().contains(query) ?? false) ||
          (p.referenceNumber?.toLowerCase().contains(query) ?? false) ||
          (p.notes?.toLowerCase().contains(query) ?? false);
      if (!matches) return false;
    }
    if (statusFilter != null && p.status != statusFilter) return false;
    if (typeFilter != null && p.paymentType != typeFilter) return false;
    return true;
  }).toList();

  filtered.sort((a, b) {
    switch (sortOption) {
      case PaymentSortOption.newestFirst:
        return b.createdAt.compareTo(a.createdAt);
      case PaymentSortOption.oldestFirst:
        return a.createdAt.compareTo(b.createdAt);
      case PaymentSortOption.amountHighToLow:
        return b.amount.compareTo(a.amount);
      case PaymentSortOption.amountLowToHigh:
        return a.amount.compareTo(b.amount);
    }
  });

  return filtered;
});

// ─────────────────────────────────────────────────────────────────────────────
// Statistics for Dashboard
// ─────────────────────────────────────────────────────────────────────────────

class PaymentStatistics {
  const PaymentStatistics({
    required this.totalPaidAmount,
    required this.totalPendingAmount,
    required this.overdueAmount,
    required this.totalPaymentsCount,
    required this.pendingPaymentsCount,
  });

  final double totalPaidAmount;
  final double totalPendingAmount;
  final double overdueAmount;
  final int totalPaymentsCount;
  final int pendingPaymentsCount;

  static const empty = PaymentStatistics(
    totalPaidAmount: 0,
    totalPendingAmount: 0,
    overdueAmount: 0,
    totalPaymentsCount: 0,
    pendingPaymentsCount: 0,
  );
}

final paymentStatisticsProvider = Provider<PaymentStatistics>((ref) {
  final payments = ref.watch(paymentsNotifierProvider).value ?? [];
  if (payments.isEmpty) return PaymentStatistics.empty;

  double totalPaid = 0;
  double totalPending = 0;
  double overdue = 0;
  int pendingCount = 0;
  final now = DateTime.now();

  for (final p in payments) {
    if (p.status == PaymentStatus.cancelled) continue;

    totalPaid += p.paidAmount;
    totalPending += p.remainingBalance;

    if (p.remainingBalance > 0) {
      pendingCount++;
      if (p.dueDate != null && p.dueDate!.isBefore(now)) {
        overdue += p.remainingBalance;
      }
    }
  }

  return PaymentStatistics(
    totalPaidAmount: totalPaid,
    totalPendingAmount: totalPending,
    overdueAmount: overdue,
    totalPaymentsCount: payments.length,
    pendingPaymentsCount: pendingCount,
  );
});
