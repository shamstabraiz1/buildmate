import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../data/labour_dummy_data.dart';
import '../widgets/labour_card.dart';

class LabourDetailsScreen extends StatefulWidget {
  const LabourDetailsScreen({required this.labourId, super.key});

  final String labourId;

  @override
  State<LabourDetailsScreen> createState() => _LabourDetailsScreenState();
}

class _LabourDetailsScreenState extends State<LabourDetailsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final worker = LabourDummyData.workers.cast<LabourModel?>().firstWhere(
          (w) => w?.id == widget.labourId,
          orElse: () => null,
        );

    if (worker == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Worker Not Found'),
        body: Center(
          child: EmptyStateWidget(
            icon: const Icon(Icons.person_off_outlined),
            title: 'Worker Not Found',
            message: 'This worker does not exist or has been removed.',
            actionLabel: 'Go Back',
            onActionPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: worker.name,
        subtitle: 'Worker Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Worker',
            onPressed: () {
              // TODO: Navigate to Edit
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: LabourCard(labour: worker, onTap: null),
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
                Tab(text: 'Attendance'),
                Tab(text: 'Payments'),
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
                _OverviewTab(labour: worker),
                _AttendanceTab(labourId: worker.id),
                _PaymentsTab(labourId: worker.id),
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
  const _OverviewTab({required this.labour});

  final LabourModel labour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surface,
              borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(context, Icons.calendar_today_outlined, 'Joined', _formatDate(labour.joinedDate)),
                const SizedBox(height: AppSpacing.md),
                _buildInfoRow(context, Icons.home_outlined, 'Address', labour.address.isNotEmpty ? labour.address : 'Not Provided'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.xxs),
            Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ─── Attendance Tab ───────────────────────────────────────────────────────────

class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab({required this.labourId});

  final String labourId;

  @override
  Widget build(BuildContext context) {
    final records = LabourDummyData.attendanceHistory.where((r) => r.labourId == labourId).toList();
    records.sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Marking attendance...')),
              );
            },
            icon: const Icon(Icons.how_to_reg_rounded),
            label: const Text('Mark Attendance'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(AppSpacing.controlHeight)),
          ),
        ),
        Expanded(
          child: records.isEmpty
              ? const Center(child: Text('No attendance records found.'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  itemCount: records.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final colorScheme = Theme.of(context).colorScheme;
                    
                    Color statusColor;
                    String statusText;
                    
                    switch (record.status) {
                      case AttendanceStatus.present:
                        statusColor = AppColors.successGreen;
                        statusText = 'Present';
                        break;
                      case AttendanceStatus.halfDay:
                        statusColor = AppColors.cautionAmber;
                        statusText = 'Half Day';
                        break;
                      case AttendanceStatus.absent:
                        statusColor = AppColors.dangerRed;
                        statusText = 'Absent';
                        break;
                    }

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.event_available_outlined, color: statusColor),
                      ),
                      title: Text(
                        '${record.date.day}/${record.date.month}/${record.date.year}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: record.overtimeHours > 0 
                        ? Text('Overtime: ${record.overtimeHours} hrs', style: TextStyle(color: colorScheme.primary))
                        : null,
                      trailing: Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ─── Payments Tab ─────────────────────────────────────────────────────────────

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab({required this.labourId});

  final String labourId;

  @override
  Widget build(BuildContext context) {
    final records = LabourDummyData.paymentsHistory.where((r) => r.labourId == labourId).toList();
    records.sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recording payment...')),
              );
            },
            icon: const Icon(Icons.payment_rounded),
            label: const Text('Record Payment'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(AppSpacing.controlHeight)),
          ),
        ),
        Expanded(
          child: records.isEmpty
              ? const Center(child: Text('No payment history found.'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  itemCount: records.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.payments_outlined, color: Theme.of(context).colorScheme.primary),
                      ),
                      title: Text(
                        '₹ ${record.amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text('${record.date.day}/${record.date.month}/${record.date.year} • ${record.method.name}'),
                      trailing: record.notes != null ? const Icon(Icons.notes_outlined, size: 16) : null,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
