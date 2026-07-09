import 'package:hive_flutter/hive_flutter.dart';
import '../models/payment_history_model.dart';
import '../models/payment_model.dart';
import 'payment_local_data_source.dart';

class PaymentHiveDataSourceImpl implements PaymentLocalDataSource {
  PaymentHiveDataSourceImpl();

  static const String _boxName = 'payments';
  static const String _historyBoxName = 'payment_history';

  Future<Box> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<Box> get _historyBox async {
    if (!Hive.isBoxOpen(_historyBoxName)) {
      return await Hive.openBox(_historyBoxName);
    }
    return Hive.box(_historyBoxName);
  }

  @override
  Future<void> addPayment(PaymentModel payment) async {
    final box = await _box;
    await box.put(payment.id, payment.toMap());
  }

  @override
  Future<void> updatePayment(PaymentModel payment) async {
    final box = await _box;
    await box.put(payment.id, payment.toMap());
  }

  @override
  Future<void> deletePayment(String id) async {
    final box = await _box;
    final map = box.get(id);
    if (map != null) {
      final Map<String, dynamic> updatedMap = Map<String, dynamic>.from(map);
      updatedMap['isDeleted'] = 1;
      updatedMap['updatedAt'] = DateTime.now().toIso8601String();
      await box.put(id, updatedMap);
    }
  }

  @override
  Future<List<PaymentModel>> getAllPayments() async {
    final box = await _box;
    final list = box.values.toList();
    
    final payments = list
        .map((e) => PaymentModel.fromMap(Map<String, dynamic>.from(e)))
        .where((e) => !e.isDeleted)
        .toList();
        
    payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return payments;
  }

  @override
  Future<PaymentModel?> getPaymentById(String id) async {
    final box = await _box;
    final map = box.get(id);
    if (map != null) {
      final e = PaymentModel.fromMap(Map<String, dynamic>.from(map));
      if (!e.isDeleted) {
        return e;
      }
    }
    return null;
  }

  @override
  Future<List<PaymentModel>> getPaymentsByProject(String projectId) async {
    final allPayments = await getAllPayments();
    return allPayments.where((e) => e.projectId == projectId).toList();
  }

  @override
  Future<List<PaymentModel>> getPaymentsByPayee(String payeeId) async {
    final allPayments = await getAllPayments();
    return allPayments.where((e) => e.payeeId == payeeId).toList();
  }

  // History Methods
  @override
  Future<List<PaymentHistoryModel>> getPaymentHistory(String paymentId) async {
    final box = await _historyBox;
    final list = box.values.toList();
    
    final history = list
        .map((e) => PaymentHistoryModel.fromMap(Map<String, dynamic>.from(e)))
        .where((e) => !e.isDeleted && e.paymentId == paymentId)
        .toList();
        
    history.sort((a, b) => a.paymentDate.compareTo(b.paymentDate));
    return history;
  }

  @override
  Future<void> addPaymentHistory(PaymentHistoryModel history) async {
    final box = await _historyBox;
    await box.put(history.id, history.toMap());
  }

  @override
  Future<void> updatePaymentHistory(PaymentHistoryModel history) async {
    final box = await _historyBox;
    await box.put(history.id, history.toMap());
  }

  @override
  Future<void> deletePaymentHistory(String id) async {
    final box = await _historyBox;
    final map = box.get(id);
    if (map != null) {
      final Map<String, dynamic> updatedMap = Map<String, dynamic>.from(map);
      updatedMap['isDeleted'] = 1;
      updatedMap['updatedAt'] = DateTime.now().toIso8601String();
      await box.put(id, updatedMap);
    }
  }
}
