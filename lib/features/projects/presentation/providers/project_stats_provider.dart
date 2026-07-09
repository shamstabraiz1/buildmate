import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_providers.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../payments/presentation/providers/payment_providers.dart';
import '../../../materials/presentation/providers/material_providers.dart';
import '../../../labour/presentation/providers/labour_providers.dart';
import '../../../labour/data/models/labour_model.dart';
import '../../../labour/data/models/attendance_model.dart';

class ProjectStats {
  const ProjectStats({
    required this.totalExpenses,
    required this.totalPayments,
    required this.remainingBudget,
    required this.labourCost,
    required this.materialCost,
    required this.totalLabour,
    required this.totalMaterials,
    required this.totalProjectCost,
    required this.outstandingPayments,
  });

  final double totalExpenses;
  final double totalPayments;
  final double remainingBudget;
  final double labourCost;
  final double materialCost;
  final int totalLabour;
  final int totalMaterials;
  final double totalProjectCost;
  final double outstandingPayments;
}

final projectStatsProvider = FutureProvider.family<ProjectStats, String>((ref, projectId) async {
  // Watch all dependent providers
  final project = await ref.watch(projectDetailsProvider(projectId).future);
  final expenses = await ref.watch(expensesByProjectProvider(projectId).future);
  final payments = await ref.watch(paymentsByProjectProvider(projectId).future);
  final materials = await ref.watch(materialsByProjectProvider(projectId).future);
  final attendance = await ref.watch(projectAttendanceProvider(projectId).future);
  final laboursList = await ref.watch(laboursNotifierProvider.future);

  // Compute Expenses
  final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + e.amount);

  // Compute Payments
  final totalPayments = payments.fold<double>(0, (sum, p) => sum + p.amount);

  // Remaining Budget & Outstanding Payments will be calculated after getting all costs
  final budget = project?.budget ?? 0;

  // Material Cost
  final materialCost = materials.fold<double>(0, (sum, m) => sum + m.totalCost);
  final totalMaterials = materials.length;

  // Labour Cost
  double labourCost = 0;
  final Set<String> uniqueLabours = {};

  for (final record in attendance) {
    uniqueLabours.add(record.labourId);
    final labour = laboursList.firstWhere(
      (l) => l.id == record.labourId, 
      orElse: () => LabourModel.create(name: 'Unknown', phone: '', role: LabourRole.helper, dailyRate: 0)
    );
    
    double dailyWage = 0;
    if (record.status == AttendanceStatus.present) {
      dailyWage = labour.dailyRate;
    } else if (record.status == AttendanceStatus.halfDay) {
      dailyWage = labour.dailyRate / 2;
    }
    
    final overtimePay = record.overtimeHours * (labour.overtimeRate ?? (labour.dailyRate / 8));
    labourCost += dailyWage + overtimePay;
  }

  final totalLabour = uniqueLabours.length;

  // Total Project Cost
  final totalProjectCost = totalExpenses + labourCost + materialCost;

  // Remaining Budget
  final remainingBudget = budget - totalProjectCost;

  // Outstanding Payments
  final outstandingPayments = totalProjectCost - totalPayments;

  return ProjectStats(
    totalExpenses: totalExpenses,
    totalPayments: totalPayments,
    remainingBudget: remainingBudget,
    labourCost: labourCost,
    materialCost: materialCost,
    totalLabour: totalLabour,
    totalMaterials: totalMaterials,
    totalProjectCost: totalProjectCost,
    outstandingPayments: outstandingPayments,
  );
});

final projectLaboursProvider = FutureProvider.family<List<LabourModel>, String>((ref, projectId) async {
  final attendance = await ref.watch(projectAttendanceProvider(projectId).future);
  final laboursList = await ref.watch(laboursNotifierProvider.future);
  
  final Set<String> uniqueLabourIds = attendance.map((a) => a.labourId).toSet();
  
  return laboursList.where((l) => uniqueLabourIds.contains(l.id)).toList();
});
