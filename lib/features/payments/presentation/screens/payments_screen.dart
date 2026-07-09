import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../../../../shared/widgets/inputs/app_search_bar.dart';
import '../../../../shared/widgets/layout/custom_scaffold.dart';
import '../../data/models/payment_model.dart';
import '../providers/payment_providers.dart';
import '../widgets/payment_card.dart';
import '../../../dashboard/presentation/widgets/dashboard_bottom_nav.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentsNotifierProvider);
    final filteredPayments = ref.watch(filteredPaymentsProvider);
    final stats = ref.watch(paymentStatisticsProvider);

    return CustomScaffold(
      title: 'Payments',
      bottomNavigationBar: const DashboardBottomNav(
        selectedDestination: DashboardNavDestination.payments,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/payments/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Payment'),
      ),
      body: paymentsAsync.when(
        data: (_) {
          return CustomScrollView(
            slivers: [
              // Statistics header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Pending',
                          amount: stats.totalPendingAmount,
                          count: stats.pendingPaymentsCount,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _StatCard(
                          title: 'Paid',
                          amount: stats.totalPaidAmount,
                          count: null,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search & Filters
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSearchBar(
                        hintText: 'Search payments...',
                        controller: _searchCtrl,
                        onChanged: (v) {
                          ref.read(paymentSearchQueryProvider.notifier).update(v);
                        },
                        onClear: () {
                          _searchCtrl.clear();
                          ref.read(paymentSearchQueryProvider.notifier).update('');
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildSortButton(context),
                            const SizedBox(width: AppSpacing.sm),
                            _buildStatusFilter(context),
                            const SizedBox(width: AppSpacing.sm),
                            _buildTypeFilter(context),
                            const SizedBox(width: AppSpacing.sm),
                            // Clear filters
                            if (ref.watch(paymentSearchQueryProvider).isNotEmpty ||
                                ref.watch(paymentStatusFilterProvider) != null ||
                                ref.watch(paymentTypeFilterProvider) != null)
                              ActionChip(
                                label: const Text('Clear Filters'),
                                avatar: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  ref.read(paymentSearchQueryProvider.notifier).update('');
                                  ref.read(paymentStatusFilterProvider.notifier).update(null);
                                  ref.read(paymentTypeFilterProvider.notifier).update(null);
                                },
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),

              // List
              if (filteredPayments.isEmpty)
                const SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icon(Icons.payment_outlined, size: 56),
                    title: 'No Payments Found',
                    message: 'No payments match your criteria.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.xxxl * 2,
                  ),
                  sliver: SliverList.separated(
                    itemCount: filteredPayments.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final payment = filteredPayments[i];
                      return PaymentCard(
                        payment: payment,
                        onTap: () => context.push('/payments/${payment.id}'),
                      );
                    },
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: EmptyStateWidget(
            icon: const Icon(Icons.error_outline),
            title: 'Error Loading Payments',
            message: err.toString(),
            actionLabel: 'Retry',
            onActionPressed: () {
              ref.read(paymentsNotifierProvider.notifier).refresh();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton(BuildContext context) {
    final sortOption = ref.watch(paymentSortOptionProvider);
    final cs = Theme.of(context).colorScheme;

    String label;
    switch (sortOption) {
      case PaymentSortOption.newestFirst:
        label = 'Newest First';
        break;
      case PaymentSortOption.oldestFirst:
        label = 'Oldest First';
        break;
      case PaymentSortOption.amountHighToLow:
        label = 'Highest Amount';
        break;
      case PaymentSortOption.amountLowToHigh:
        label = 'Lowest Amount';
        break;
    }

    return ActionChip(
      avatar: const Icon(Icons.sort, size: 16),
      label: Text(label),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (ctx) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text('Sort By',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ...PaymentSortOption.values.map((o) {
                    return ListTile(
                      title: Text(o.name),
                      trailing: sortOption == o
                          ? Icon(Icons.check, color: cs.primary)
                          : null,
                      onTap: () {
                        ref.read(paymentSortOptionProvider.notifier).update(o);
                        Navigator.pop(ctx);
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusFilter(BuildContext context) {
    final currentFilter = ref.watch(paymentStatusFilterProvider);

    return PopupMenuButton<PaymentStatus?>(
      initialValue: currentFilter,
      onSelected: (v) {
        ref.read(paymentStatusFilterProvider.notifier).update(v);
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: null,
            child: Text('All Statuses'),
          ),
          const PopupMenuDivider(),
          ...PaymentStatus.values.map(
            (s) => PopupMenuItem(
              value: s,
              child: Text(PaymentModel.statusLabels[s] ?? s.name),
            ),
          ),
        ];
      },
      child: Chip(
        label: Text(currentFilter == null
            ? 'Status: All'
            : 'Status: ${PaymentModel.statusLabels[currentFilter]}'),
        backgroundColor: currentFilter != null
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
      ),
    );
  }

  Widget _buildTypeFilter(BuildContext context) {
    final currentFilter = ref.watch(paymentTypeFilterProvider);

    return PopupMenuButton<PaymentType?>(
      initialValue: currentFilter,
      onSelected: (v) {
        ref.read(paymentTypeFilterProvider.notifier).update(v);
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: null,
            child: Text('All Types'),
          ),
          const PopupMenuDivider(),
          ...PaymentType.values.map(
            (t) => PopupMenuItem(
              value: t,
              child: Text(PaymentModel.typeLabels[t] ?? t.name),
            ),
          ),
        ];
      },
      child: Chip(
        label: Text(currentFilter == null
            ? 'Type: All'
            : 'Type: ${PaymentModel.typeLabels[currentFilter]}'),
        backgroundColor: currentFilter != null
            ? Theme.of(context).colorScheme.tertiaryContainer
            : null,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.amount,
    required this.count,
    required this.color,
  });

  final String title;
  final double amount;
  final int? count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Currency format
    final formattedAmount = amount.toStringAsFixed(0); // Simplified format for top bar

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (count != null && count! > 0) ...[
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Rs. $formattedAmount',
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
