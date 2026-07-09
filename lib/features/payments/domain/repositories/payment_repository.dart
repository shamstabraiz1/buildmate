import '../../data/models/payment_history_model.dart';
import '../../data/models/payment_model.dart';

abstract class PaymentRepository {
  Future<void> addPayment(PaymentModel payment);
  Future<void> updatePayment(PaymentModel payment);
  Future<void> deletePayment(String id);
  Future<List<PaymentModel>> getAllPayments();
  Future<PaymentModel?> getPaymentById(String id);
  Future<List<PaymentModel>> getPaymentsByProjectId(String projectId);
  Future<List<PaymentModel>> getPaymentsByPayeeId(String payeeId);

  // History Methods
  Future<List<PaymentHistoryModel>> getPaymentHistory(String paymentId);
  Future<void> addPaymentHistory(PaymentHistoryModel history);
  Future<void> updatePaymentHistory(PaymentHistoryModel history);
  Future<void> deletePaymentHistory(String id);
}
