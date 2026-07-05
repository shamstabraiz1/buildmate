import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../data/materials_dummy_data.dart';
import '../widgets/material_card.dart';
import '../widgets/supplier_card.dart';

class MaterialDetailsScreen extends StatefulWidget {
  const MaterialDetailsScreen({required this.materialId, super.key});

  final String materialId;

  @override
  State<MaterialDetailsScreen> createState() => _MaterialDetailsScreenState();
}

class _MaterialDetailsScreenState extends State<MaterialDetailsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final material = MaterialsDummyData.materials.cast<MaterialModel?>().firstWhere(
          (m) => m?.id == widget.materialId,
          orElse: () => null,
        );

    if (material == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Material Not Found'),
        body: Center(
          child: EmptyStateWidget(
            icon: const Icon(Icons.error_outline_rounded),
            title: 'Material Not Found',
            message: 'This material does not exist or has been removed.',
            actionLabel: 'Go Back',
            onActionPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: material.name,
        subtitle: 'Material Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Material',
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: MaterialCard(material: material, onTap: null),
          ),
          
          // TabBar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Stock Ledger'),
              ],
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(material: material),
                _StockLedgerTab(materialId: material.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.material});

  final MaterialModel material;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final supplier = MaterialsDummyData.suppliers.cast<SupplierModel?>().firstWhere(
          (s) => s?.id == material.supplierId,
          orElse: () => null,
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory Metrics',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  title: 'Reorder Level',
                  value: '${material.reorderLevel.toStringAsFixed(0)} ${material.unit}',
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.cautionAmber,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildMetricCard(
                  context,
                  title: 'Avg Unit Price',
                  value: '₹ ${material.averageUnitPrice.toStringAsFixed(0)}',
                  icon: Icons.price_change_outlined,
                  color: AppColors.safetyOrange,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (supplier != null) ...[
            Text(
              'Primary Supplier',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SupplierCard(supplier: supplier, onTap: null),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.lg)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stock Ledger Tab ─────────────────────────────────────────────────────────

class _StockLedgerTab extends StatelessWidget {
  const _StockLedgerTab({required this.materialId});

  final String materialId;

  @override
  Widget build(BuildContext context) {
    final records = MaterialsDummyData.transactions.where((t) => t.materialId == materialId).toList();
    records.sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: const Text('Record Stock Entry'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(AppSpacing.controlHeight)),
          ),
        ),
        Expanded(
          child: records.isEmpty
              ? const Center(child: Text('No transaction history.'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  itemCount: records.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final isIncoming = record.type == TransactionType.incoming;
                    
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: (isIncoming ? AppColors.successGreen : AppColors.dangerRed).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isIncoming ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          color: isIncoming ? AppColors.successGreen : AppColors.dangerRed,
                        ),
                      ),
                      title: Text(
                        '${isIncoming ? '+' : '-'}${record.quantity.toStringAsFixed(record.quantity % 1 == 0 ? 0 : 2)} units',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isIncoming ? AppColors.successGreen : AppColors.dangerRed,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text('${record.date.day}/${record.date.month}/${record.date.year} • ${record.date.hour}:${record.date.minute.toString().padLeft(2, '0')}'),
                          if (record.notes != null) ...[
                            const SizedBox(height: 2),
                            Text(record.notes!, style: const TextStyle(fontStyle: FontStyle.italic)),
                          ],
                        ],
                      ),
                      isThreeLine: record.notes != null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
