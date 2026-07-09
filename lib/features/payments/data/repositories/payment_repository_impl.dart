import '../models/payment_history_model.dart';
import '../models/payment_model.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../data/datasources/payment_local_data_source.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../expenses/data/models/expense_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._dataSource, this._expenseRepository);

  final PaymentLocalDataSource _dataSource;
  final ExpenseRepository _expenseRepository;

  @override
  Future<void> addPayment(PaymentModel payment) async {
    final updatedPayment = PaymentModel.calculateState(payment, 0);
    await _dataSource.addPayment(updatedPayment);
    await _updateLinkedEntity(updatedPayment);
  }

  @override
  Future<void> updatePayment(PaymentModel payment) async {
    // We need to fetch history to calculate state correctly
    final history = await getPaymentHistory(payment.id);
    final totalPaid = history.fold<double>(0.0, (sum, h) => sum + h.amount);
    final updatedPayment = PaymentModel.calculateState(payment, totalPaid);
    
    await _dataSource.updatePayment(updatedPayment);
    await _updateLinkedEntity(updatedPayment);
  }

  @override
  Future<void> deletePayment(String id) async {
    final payment = await getPaymentById(id);
    if (payment != null) {
      await _dataSource.deletePayment(id);
      
      // We must also update the linked entity by recalculating its payments
      if (payment.paymentType == PaymentType.expense) {
        await _recalculateExpensePayments(payment.payeeId);
      }
    }
  }

  @override
  Future<List<PaymentModel>> getAllPayments() async {
    return await _dataSource.getAllPayments();
  }

  @override
  Future<PaymentModel?> getPaymentById(String id) async {
    return await _dataSource.getPaymentById(id);
  }

  @override
  Future<List<PaymentModel>> getPaymentsByProjectId(String projectId) async {
    return await _dataSource.getPaymentsByProject(projectId);
  }

  @override
  Future<List<PaymentModel>> getPaymentsByPayeeId(String payeeId) async {
    return await _dataSource.getPaymentsByPayee(payeeId);
  }

  // History Methods
  @override
  Future<List<PaymentHistoryModel>> getPaymentHistory(String paymentId) async {
    return await _dataSource.getPaymentHistory(paymentId);
  }

  @override
  Future<void> addPaymentHistory(PaymentHistoryModel history) async {
    await _dataSource.addPaymentHistory(history);
    await _recalculatePaymentState(history.paymentId);
  }

  @override
  Future<void> updatePaymentHistory(PaymentHistoryModel history) async {
    await _dataSource.updatePaymentHistory(history);
    await _recalculatePaymentState(history.paymentId);
  }


  Future<void> deleteHistoryRecord(PaymentHistoryModel history) async {
    await _dataSource.deletePaymentHistory(history.id);
    await _recalculatePaymentState(history.paymentId);
  }

  @override
  Future<void> deletePaymentHistory(String id) async {
    await _dataSource.deletePaymentHistory(id);
    // Note: Caller MUST call recalculate manually if using this directly without paymentId
  }

  Future<void> _recalculatePaymentState(String paymentId) async {
    final payment = await getPaymentById(paymentId);
    if (payment != null) {
      final history = await getPaymentHistory(paymentId);
      final totalPaid = history.fold<double>(0.0, (sum, h) => sum + h.amount);
      final updatedPayment = PaymentModel.calculateState(payment, totalPaid);
      await _dataSource.updatePayment(updatedPayment);
      await _updateLinkedEntity(updatedPayment);
    }
  }

  Future<void> _updateLinkedEntity(PaymentModel payment) async {
    if (payment.paymentType == PaymentType.expense) {
      await _recalculateExpensePayments(payment.payeeId);
    }
  }

  Future<void> _recalculateExpensePayments(String expenseId) async {
    final expense = await _expenseRepository.getExpenseById(expenseId);
    if (expense == null) return;

    // Get all non-deleted payments for this expense
    final allPayments = await getPaymentsByPayeeId(expenseId);
    
    // Sum the paidAmount from all payments (assuming each payment represents installments for this expense)
    // Wait, if a payment is for an expense, its `paidAmount` represents how much has been paid towards that payment invoice.
    // If we only have ONE PaymentModel per Expense, the Expense's paidAmount is the PaymentModel's paidAmount.
    // If there can be MULTIPLE PaymentModels per Expense, we sum the paidAmount of all PaymentModels.
    double totalPaid = 0.0;
    for (var p in allPayments) {
      if (p.status != PaymentStatus.cancelled) {
        totalPaid += p.paidAmount;
      }
    }

    double newRemaining = expense.amount - totalPaid;
    ExpenseStatus newStatus;
    if (newRemaining <= 0) {
      newStatus = ExpenseStatus.paid;
      newRemaining = 0;
    } else if (totalPaid > 0) {
      newStatus = ExpenseStatus.partiallyPaid;
    } else {
      newStatus = ExpenseStatus.pending;
    }

    final updatedExpense = expense.copyWith(
      paidAmount: totalPaid,
      remainingBalance: newRemaining,
      status: newStatus,
    );

    await _expenseRepository.updateExpense(updatedExpense);
  }
}
