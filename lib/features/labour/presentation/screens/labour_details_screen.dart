import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../../shared/widgets/feedback/app_loading_indicator.dart';
import '../../../../shared/widgets/feedback/empty_state_widget.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/labour_model.dart';
import '../providers/labour_providers.dart';
import '../widgets/labour_card.dart';
import 'add_labour_screen.dart';

class LabourDetailsScreen extends ConsumerStatefulWidget {
  const LabourDetailsScreen({required this.labourId, super.key});

  final String labourId;

  @override
  ConsumerState<LabourDetailsScreen> createState() => _LabourDetailsScreenState();
}

class _LabourDetailsScreenState extends ConsumerState<LabourDetailsScreen> with SingleTickerProviderStateMixin {
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
    final laboursState = ref.watch(laboursNotifierProvider);

    return laboursState.when(
      data: (labours) {
        final worker = labours.where((w) => w.id == widget.labourId).firstOrNull;

        if (worker == null) {
          return Scaffold(
            appBar: const CustomAppBar(title: 'Worker Not Found'),
            body: Center(
              child: EmptyStateWidget(
                icon: const Icon(Icons.person_off_outlined, size: 64),
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddLabourScreen(labourToEdit: worker),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: colorScheme.error,
                tooltip: 'Delete Worker',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Worker'),
                      content: const Text('Are you sure you want to delete this worker? This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            foregroundColor: colorScheme.onError,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(laboursNotifierProvider.notifier).deleteLabour(worker.id);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
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
                    Tab(text: 'Overview & Wages'),
                    Tab(text: 'Attendance'),
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
                    _AttendanceTab(labour: worker),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: AppLoadingIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.labour});

  final LabourModel labour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final attendanceState = ref.watch(attendanceNotifierProvider(labour.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic Wage Card
          attendanceState.when(
            data: (records) {
              int present = 0;
              int halfDay = 0;
              double totalOvertime = 0.0;

              for (final r in records) {
                if (r.status == AttendanceStatus.present) present++;
                if (r.status == AttendanceStatus.halfDay) halfDay++;
                totalOvertime += r.overtimeHours;
              }

              final otRate = labour.overtimeRate ?? (labour.dailyRate / 8);
              final totalWages = (present * labour.dailyRate) + (halfDay * (labour.dailyRate / 2)) + (totalOvertime * otRate);

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.primary.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Wages Earned', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onPrimaryContainer)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppFormatters.currency(totalWages),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.lg,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _buildStat('Present', '$present days', colorScheme),
                        _buildStat('Half Day', '$halfDay days', colorScheme),
                        _buildStat('Overtime', '${totalOvertime.toStringAsFixed(1)} hrs', colorScheme),
                      ],
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('Failed to load wages: $e'),
          ),

          // Worker Details
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
                Text('Personal Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.md),
                _buildInfoRow(context, Icons.credit_card_outlined, 'CNIC', labour.cnic ?? 'Not Provided'),
                const SizedBox(height: AppSpacing.md),
                _buildInfoRow(context, Icons.home_outlined, 'Address', labour.address ?? 'Not Provided'),
                if (labour.notes != null && labour.notes!.isNotEmpty) ...[
                  Text('Additional Info', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow(context, Icons.notes_outlined, 'Notes', labour.notes!),
                  const Divider(height: AppSpacing.xxl),
                ],

                Text('Work Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.md),
                _buildInfoRow(context, Icons.more_time_rounded, 'Overtime Rate', labour.overtimeRate != null ? '${AppFormatters.currency(labour.overtimeRate!)} / hr' : 'Default (Daily / 8)'),
                const SizedBox(height: AppSpacing.md),
                _buildInfoRow(context, Icons.calendar_today_outlined, 'Joined', AppFormatters.date(labour.createdAt)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.xxs),
              Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Attendance Tab ───────────────────────────────────────────────────────────

class _AttendanceTab extends ConsumerStatefulWidget {
  const _AttendanceTab({required this.labour});
  
  final LabourModel labour;

  @override
  ConsumerState<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<_AttendanceTab> {
  Future<void> _showMarkAttendanceDialog() async {
    final projects = await ref.read(projectsNotifierProvider.future);
    
    if (!mounted) return;
    
    DateTime selectedDate = DateTime.now();
    AttendanceStatus selectedStatus = AttendanceStatus.present;
    String? selectedProjectId;
    
    if (projects.isNotEmpty) {
      selectedProjectId = projects.first.id;
    }
    
    final otCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Mark Attendance'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (projects.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: Text('No projects available. Please create a project first.', style: TextStyle(color: Colors.red)),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: selectedProjectId,
                        decoration: const InputDecoration(labelText: 'Project'),
                        items: projects.map((p) {
                          return DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => selectedProjectId = v),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    // Date Picker (Mocked as button for simplicity, can use showDatePicker)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(AppFormatters.date(selectedDate)),
                      trailing: const Icon(Icons.edit, size: 16),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setState(() => selectedDate = d);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<AttendanceStatus>(
                      initialValue: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: AttendanceStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(AttendanceModel.statusLabels[status] ?? ''),
                        );
                      }).toList(),
                      onChanged: (v) => selectedStatus = v!,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: otCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Overtime Hours (Optional)',
                        prefixIcon: Icon(Icons.more_time),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(
                  onPressed: selectedProjectId == null ? null : () async {
                    final ot = double.tryParse(otCtrl.text) ?? 0.0;
                    final att = AttendanceModel.create(
                      projectId: selectedProjectId!,
                      labourId: widget.labour.id,
                      date: selectedDate,
                      status: selectedStatus,
                      overtimeHours: ot,
                    );
                    await ref.read(attendanceMutationProvider.notifier).markAttendance(att);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceNotifierProvider(widget.labour.id));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: FilledButton.icon(
            onPressed: _showMarkAttendanceDialog,
            icon: const Icon(Icons.how_to_reg_rounded),
            label: const Text('Mark Attendance'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(AppSpacing.controlHeight)),
          ),
        ),
        Expanded(
          child: attendanceState.when(
            data: (records) {
              if (records.isEmpty) {
                return const Center(child: Text('No attendance records found.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                itemCount: records.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final record = records[index];
                  final colorScheme = Theme.of(context).colorScheme;
                  
                  Color statusColor = colorScheme.primary;
                  String statusText = AttendanceModel.statusLabels[record.status] ?? '';
                  
                  switch (record.status) {
                    case AttendanceStatus.present:
                      statusColor = AppColors.successGreen;
                      break;
                    case AttendanceStatus.halfDay:
                      statusColor = AppColors.cautionAmber;
                      break;
                    case AttendanceStatus.absent:
                      statusColor = AppColors.dangerRed;
                      break;
                    case AttendanceStatus.leave:
                      statusColor = colorScheme.primary;
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
                      AppFormatters.date(record.date),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: record.overtimeHours > 0 
                      ? Text('Overtime: ${record.overtimeHours} hrs', style: TextStyle(color: colorScheme.primary))
                      : null,
                    trailing: Text(
                      statusText,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                    onLongPress: () async {
                      // Option to delete attendance
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Record'),
                          content: const Text('Delete this attendance record?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true), 
                              style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                              child: const Text('Delete')
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ref.read(attendanceMutationProvider.notifier).deleteAttendance(record.id, widget.labour.id, record.projectId);
                      }
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error loading attendance: $e')),
          ),
        ),
      ],
    );
  }
}
