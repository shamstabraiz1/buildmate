import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/layout/custom_app_bar.dart';
import '../../data/models/expense_model.dart';
import '../providers/expense_providers.dart';
import '../widgets/add_expense_form.dart';
import '../../../../shared/widgets/feedback/app_delete_dialog.dart';

class AddExpenseScreen extends ConsumerWidget {
  const AddExpenseScreen({this.expense, this.initialProjectId, super.key});

  final ExpenseModel? expense;
  final String? initialProjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final isEditing = expense != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
      child: Scaffold(
        appBar: CustomAppBar(
          title: isEditing ? 'Edit Expense' : 'Add Expense',
          subtitle: isEditing ? 'Update expense details' : 'Log a new expense record',
          actions: isEditing
              ? [
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete Expense',
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ]
              : null,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxxl,
                ),
                child: AddExpenseForm(
                  expense: expense,
                  initialProjectId: initialProjectId,
                  onSave: (data) {
                    if (isEditing) {
                      final updatedExpense = expense!.copyWith(
                        projectId: data['projectId'],
                        categoryId: data['categoryId'],
                        amount: data['amount'],
                        date: data['date'],
                        quantity: data['quantity'],
                        unit: data['unit'],
                        vendor: data['vendor'],
                        paymentMethod: data['paymentMethod'],
                        status: data['status'],
                        notes: data['notes'],
                      );
                      ref.read(expensesNotifierProvider.notifier).updateExpense(updatedExpense);
                    } else {
                      final newExpense = ExpenseModel.create(
                        projectId: data['projectId'],
                        categoryId: data['categoryId'],
                        amount: data['amount'],
                        date: data['date'],
                        quantity: data['quantity'],
                        unit: data['unit'],
                        vendor: data['vendor'],
                        paymentMethod: data['paymentMethod'],
                        status: data['status'],
                        notes: data['notes'],
                      );
                      ref.read(expensesNotifierProvider.notifier).addExpense(newExpense);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Expense ${isEditing ? 'updated' : 'added'} successfully.',
                        ),
                        backgroundColor: colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  onCancel: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const AppDeleteDialog(
        title: 'Delete Expense',
        message: 'Are you sure you want to delete this expense? This action cannot be undone.',
      ),
    );

    if (result == true && context.mounted) {
      ref.read(expensesNotifierProvider.notifier).deleteExpense(expense!.id);
      Navigator.of(context).pop();
    }
  }
}
