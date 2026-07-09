import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../../core/database/database_helper.dart';
import '../models/payment_history_model.dart';
import '../models/payment_model.dart';

abstract class PaymentLocalDataSource {
  Future<List<PaymentModel>> getAllPayments();
  Future<List<PaymentModel>> getPaymentsByProject(String projectId);
  Future<List<PaymentModel>> getPaymentsByPayee(String payeeId);
  Future<PaymentModel?> getPaymentById(String id);
  Future<void> addPayment(PaymentModel payment);
  Future<void> updatePayment(PaymentModel payment);
  Future<void> deletePayment(String id);

  // History Methods
  Future<List<PaymentHistoryModel>> getPaymentHistory(String paymentId);
  Future<void> addPaymentHistory(PaymentHistoryModel history);
  Future<void> updatePaymentHistory(PaymentHistoryModel history);
  Future<void> deletePaymentHistory(String id);
}

class PaymentLocalDataSourceImpl implements PaymentLocalDataSource {
  const PaymentLocalDataSourceImpl(this.dbHelper);

  final DatabaseHelper dbHelper;

  @override
  Future<List<PaymentModel>> getAllPayments() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => PaymentModel.fromMap(map)).toList();
  }

  @override
  Future<List<PaymentModel>> getPaymentsByProject(String projectId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'projectId = ? AND isDeleted = ?',
      whereArgs: [projectId, 0],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => PaymentModel.fromMap(map)).toList();
  }

  @override
  Future<List<PaymentModel>> getPaymentsByPayee(String payeeId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payments',
      where: 'payeeId = ? AND isDeleted = ?',
      whereArgs: [payeeId, 0],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => PaymentModel.fromMap(map)).toList();
  }

  @override
  Future<PaymentModel?> getPaymentById(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'payments',
      where: 'id = ? AND isDeleted = ?',
      whereArgs: [id, 0],
    );
    if (maps.isNotEmpty) {
      return PaymentModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> addPayment(PaymentModel payment) async {
    final db = await dbHelper.database;
    await db.insert(
      'payments',
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updatePayment(PaymentModel payment) async {
    final db = await dbHelper.database;
    await db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  @override
  Future<void> deletePayment(String id) async {
    final db = await dbHelper.database;
    await db.update(
      'payments',
      {'isDeleted': 1, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<PaymentHistoryModel>> getPaymentHistory(String paymentId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'payment_history',
      where: 'paymentId = ? AND isDeleted = ?',
      whereArgs: [paymentId, 0],
      orderBy: 'paymentDate ASC',
    );
    return maps.map((map) => PaymentHistoryModel.fromMap(map)).toList();
  }

  @override
  Future<void> addPaymentHistory(PaymentHistoryModel history) async {
    final db = await dbHelper.database;
    await db.insert(
      'payment_history',
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updatePaymentHistory(PaymentHistoryModel history) async {
    final db = await dbHelper.database;
    await db.update(
      'payment_history',
      history.toMap(),
      where: 'id = ?',
      whereArgs: [history.id],
    );
  }

  @override
  Future<void> deletePaymentHistory(String id) async {
    final db = await dbHelper.database;
    await db.update(
      'payment_history',
      {'isDeleted': 1, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
