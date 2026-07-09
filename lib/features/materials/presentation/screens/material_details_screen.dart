import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../shared/widgets/feedback/app_loading_indicator.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../../vendors/presentation/providers/vendor_providers.dart';
import '../../data/models/material_model.dart';
import '../providers/material_providers.dart';
import '../widgets/material_stats_row.dart';
import '../widgets/transaction_list_tile.dart';
import 'add_material_screen.dart';
import 'add_transaction_screen.dart';

class MaterialDetailsScreen extends ConsumerStatefulWidget {
  const MaterialDetailsScreen({required this.materialId, super.key});

  final String materialId;

  @override
  ConsumerState<MaterialDetailsScreen> createState() =>
      _MaterialDetailsScreenState();
}

class _MaterialDetailsScreenState extends ConsumerState<MaterialDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    // Find material from cached list
    final allMaterials =
        ref.watch(materialsNotifierProvider).value ?? [];
    final material = allMaterials
        .cast<MaterialModel?>()
        .firstWhere((m) => m?.id == widget.materialId, orElse: () => null);

    if (material == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Material'),
        body: EmptyStateWidget(
          icon: const Icon(Icons.error_outline_rounded, size: 64),
          title: 'Material Not Found',
          message:
              'This material does not exist or has been removed.',
          actionLabel: 'Go Back',
          onActionPressed: () => Navigator.of(context).pop(),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: material.name,
        subtitle: material.materialNumber,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Material',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      AddMaterialScreen(material: material),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: cs.error),
            tooltip: 'Delete Material',
            onPressed: () => _confirmDelete(context, material),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Material Header ────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(
                bottom: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image or icon
                    _buildHeroImage(material, cs),
                    const SizedBox(width: AppSpacing.md),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(material).withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(AppRadius.xxl),
                              ),
                            ),
                            child: Text(
                              MaterialModel.statusLabels[material.status] ??
                                  '',
                              style:
                                  theme.textTheme.labelSmall?.copyWith(
                                color: _statusColor(material),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            material.displayCategory,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            material.formattedUnitPrice,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.primary,
                            ),
                          ),
                          Text(
                            'per ${material.unit}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Stats row
                MaterialStatsRow(material: material),
              ],
            ),
          ),

          // ── Tabs ───────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabs,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Stock Ledger'),
              ],
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurfaceVariant,
              indicatorColor: cs.primary,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _OverviewTab(material: material),
                _StockLedgerTab(material: material),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(MaterialModel material, ColorScheme cs) {
    if (material.imagePath != null &&
        material.imagePath!.isNotEmpty &&
        !kIsWeb) {
      return ClipRRect(
        borderRadius:
            const BorderRadius.all(Radius.circular(AppRadius.md)),
        child: Image.file(
          File(material.imagePath!),
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _iconBox(material, cs),
        ),
      );
    }
    return _iconBox(material, cs);
  }

  Widget _iconBox(MaterialModel material, ColorScheme cs) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
      ),
      child: Icon(
        MaterialModel.categoryIcons[material.category] ??
            Icons.category_outlined,
        color: cs.onPrimaryContainer,
        size: 36,
      ),
    );
  }

  Color _statusColor(MaterialModel m) {
    if (m.isOutOfStock) return AppColors.dangerRed;
    if (m.isLowStock) return AppColors.cautionAmber;
    return AppColors.successGreen;
  }

  void _confirmDelete(BuildContext context, MaterialModel material) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text(
          'Remove "${material.name}" from your inventory? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(materialsNotifierProvider.notifier)
                  .deleteMaterial(material.id);
              Navigator.of(context).pop(); // Return to list
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.material});

  final MaterialModel material;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    // Vendor lookup
    final vendor = material.vendorId != null
        ? ref.watch(vendorByIdProvider(material.vendorId!))
        : null;


    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Pricing Summary ──────────────────────────────────────────
          Text('Pricing & Cost',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Unit Price',
                  value: material.formattedUnitPrice,
                  icon: Icons.price_change_outlined,
                  color: cs.primary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MetricCard(
                  title: 'Total Cost',
                  value: material.formattedTotalCost,
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.successGreen,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Reorder At',
                  value:
                      '${material.reorderLevel.toStringAsFixed(material.reorderLevel % 1 == 0 ? 0 : 2)} ${material.unit}',
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.cautionAmber,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _MetricCard(
                  title: 'Unit',
                  value: material.unit,
                  icon: Icons.straighten_outlined,
                  color: cs.secondary,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          // ── Vendor Info ──────────────────────────────────────────────
          if (vendor != null && vendor.id.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Primary Vendor',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.5)),
                borderRadius:
                    const BorderRadius.all(Radius.circular(AppRadius.md)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        vendor.initials,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: cs.onSecondaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(vendor.name,
                            style:
                                theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                        if (vendor.phone != null)
                          Text(vendor.phone!,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: cs.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Notes ────────────────────────────────────────────────────
          if (material.notes != null &&
              material.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('Notes',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color:
                    cs.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius:
                    const BorderRadius.all(Radius.circular(AppRadius.md)),
              ),
              child: Text(
                material.notes!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),

          // ── Audit ────────────────────────────────────────────────────
          Text('Record Info',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          _AuditRow(
            label: 'Created',
            value: AppFormatters.dateTime(material.createdAt),
          ),
          _AuditRow(
            label: 'Last Updated',
            value: AppFormatters.dateTime(material.updatedAt),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest.withValues(alpha: 0.3)
            : cs.surface,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
        borderRadius:
            const BorderRadius.all(Radius.circular(AppRadius.md)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                title,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditRow extends StatelessWidget {
  const _AuditRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
          Text(value,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Stock Ledger Tab ─────────────────────────────────────────────────────────

class _StockLedgerTab extends ConsumerWidget {
  const _StockLedgerTab({required this.material});

  final MaterialModel material;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnsAsync =
        ref.watch(materialTransactionsProvider(material.id));

    return Column(
      children: [
        // Record entry button
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            0,
          ),
          child: FilledButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) =>
                    AddTransactionScreen(material: material),
              );
            },
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: const Text('Record Stock Entry'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(AppSpacing.controlHeight),
            ),
          ),
        ),

        Expanded(
          child: txnsAsync.when(
            data: (txns) {
              if (txns.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icon(Icons.receipt_long_outlined, size: 56),
                  title: 'No stock entries yet',
                  message:
                      'Tap "Record Stock Entry" to log the first transaction.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: txns.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final txn = txns[i];
                  // Vendor name lookup
                  final vendor = txn.vendorId != null
                      ? ref.watch(vendorByIdProvider(txn.vendorId!))
                      : null;
                  return TransactionListTile(
                    transaction: txn,
                    unit: material.unit,
                    vendorName: vendor?.id.isNotEmpty == true
                        ? vendor!.name
                        : null,
                    onDelete: () => _confirmDeleteTxn(context, ref, txn),
                  );
                },
              );
            },
            loading: () => const Center(child: AppLoadingIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  void _confirmDeleteTxn(
    BuildContext context,
    WidgetRef ref,
    dynamic txn,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content:
            const Text('Remove this stock transaction? Quantities will be reversed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(materialsNotifierProvider.notifier)
                  .deleteTransaction(txn.id, txn.materialId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
