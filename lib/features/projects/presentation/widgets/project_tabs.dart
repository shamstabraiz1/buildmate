import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../data/models/project_model.dart';
import '../providers/project_stats_provider.dart';
import 'project_summary_card.dart';

import '../../../expenses/presentation/widgets/expense_card.dart';
import '../../../labour/presentation/widgets/labour_card.dart';
import '../../../materials/presentation/widgets/material_card.dart';
import '../../../payments/presentation/widgets/payment_card.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../payments/presentation/providers/payment_providers.dart';
import '../../../materials/presentation/providers/material_providers.dart';
import '../../../../shared/widgets/feedback/app_loading_indicator.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the tabs for the project details screen.
class ProjectTabs extends StatefulWidget {
  const ProjectTabs({
    required this.project,
    super.key,
  });

  final ProjectModel project;

  @override
  State<ProjectTabs> createState() => _ProjectTabsState();
}

class _ProjectTabsState extends State<ProjectTabs> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _tabs = const [
    Tab(text: 'Overview'),
    Tab(text: 'Expenses'),
    Tab(text: 'Labours'),
    Tab(text: 'Materials'),
    Tab(text: 'Reports'),
    Tab(text: 'Payments'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: _tabs,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            dividerColor: Colors.transparent,
          ),
        ),

        // TabBarView content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(project: widget.project),
              _ProjectExpensesTab(projectId: widget.project.id),
              _ProjectLaboursTab(projectId: widget.project.id),
              _ProjectMaterialsTab(projectId: widget.project.id),
              const _PlaceholderTab(icon: Icons.bar_chart_outlined, title: 'Reports'),
              _ProjectPaymentsTab(projectId: widget.project.id),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(projectStatsProvider(project.id));
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic summary card (Project Name, Budget, etc.)
          ProjectSummaryCard(project: project),
          const SizedBox(height: AppSpacing.xl),
          
          Text(
            'Project Dashboard',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          statsAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: AppLoadingIndicator())),
            error: (err, stack) => Center(child: Text('Error computing stats: $err')),
            data: (stats) {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(title: 'Total Expenses', value: '₹ ${stats.totalExpenses.toStringAsFixed(0)}', icon: Icons.receipt_long, color: Colors.orange),
                  _StatCard(title: 'Remaining Budget', value: '₹ ${stats.remainingBudget.toStringAsFixed(0)}', icon: Icons.account_balance_wallet, color: stats.remainingBudget < 0 ? Colors.red : Colors.green),
                  _StatCard(title: 'Total Payments', value: '₹ ${stats.totalPayments.toStringAsFixed(0)}', icon: Icons.payments, color: Colors.blue),
                  _StatCard(title: 'Outstanding Pay', value: '₹ ${stats.outstandingPayments.toStringAsFixed(0)}', icon: Icons.money_off, color: Colors.redAccent),
                  _StatCard(title: 'Labour Cost', value: '₹ ${stats.labourCost.toStringAsFixed(0)}', icon: Icons.engineering, color: Colors.teal),
                  _StatCard(title: 'Material Cost', value: '₹ ${stats.materialCost.toStringAsFixed(0)}', icon: Icons.inventory_2, color: Colors.brown),
                  _StatCard(title: 'Total Labour', value: '${stats.totalLabour} assigned', icon: Icons.group, color: Colors.indigo),
                  _StatCard(title: 'Total Materials', value: '${stats.totalMaterials} types', icon: Icons.category, color: Colors.deepPurple),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── TABS IMPLEMENTATION ──────────────────────────────────────────────────

class _ProjectExpensesTab extends ConsumerWidget {
  const _ProjectExpensesTab({required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesByProjectProvider(projectId));
    return expensesAsync.when(
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (expenses) {
        if (expenses.isEmpty) return const EmptyStateWidget(icon: Icon(Icons.receipt_long), title: 'No Expenses', message: 'No expenses logged for this project yet.');
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: expenses.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (ctx, i) => ExpenseCard(expense: expenses[i], projectName: '', onTap: () {}),
        );
      },
    );
  }
}

class _ProjectLaboursTab extends ConsumerWidget {
  const _ProjectLaboursTab({required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final laboursAsync = ref.watch(projectLaboursProvider(projectId));
    return laboursAsync.when(
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (labours) {
        if (labours.isEmpty) return const EmptyStateWidget(icon: Icon(Icons.people), title: 'No Labours', message: 'No labour assigned to this project yet.');
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: labours.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (ctx, i) => LabourCard(labour: labours[i], onTap: () {}),
        );
      },
    );
  }
}

class _ProjectMaterialsTab extends ConsumerWidget {
  const _ProjectMaterialsTab({required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(materialsByProjectProvider(projectId));
    return materialsAsync.when(
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (materials) {
        if (materials.isEmpty) return const EmptyStateWidget(icon: Icon(Icons.inventory_2), title: 'No Materials', message: 'No materials added to this project yet.');
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: materials.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (ctx, i) => MaterialCard(material: materials[i], onTap: () {}),
        );
      },
    );
  }
}

class _ProjectPaymentsTab extends ConsumerWidget {
  const _ProjectPaymentsTab({required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsByProjectProvider(projectId));
    return paymentsAsync.when(
      loading: () => const Center(child: AppLoadingIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (payments) {
        if (payments.isEmpty) return const EmptyStateWidget(icon: Icon(Icons.payments), title: 'No Payments', message: 'No payments made for this project yet.');
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: payments.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (ctx, i) => PaymentCard(payment: payments[i], onTap: () {}),
        );
      },
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Data will be displayed here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
