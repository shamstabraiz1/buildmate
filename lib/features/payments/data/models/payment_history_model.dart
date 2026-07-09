import 'package:uuid/uuid.dart';
import 'payment_model.dart';

class PaymentHistoryModel {
  const PaymentHistoryModel({
    required this.id,
    required this.uuid,
    required this.paymentId,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod = PaymentMethod.cash,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  final String id;
  final String uuid;
  final String paymentId;
  final double amount;
  final DateTime paymentDate;
  final PaymentMethod paymentMethod;
  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'paymentId': paymentId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory PaymentHistoryModel.fromMap(Map<String, dynamic> map) {
    return PaymentHistoryModel(
      id: map['id'] as String,
      uuid: map['uuid'] as String,
      paymentId: map['paymentId'] as String,
      amount: (map['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(map['paymentDate'] as String),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }

  factory PaymentHistoryModel.create({
    required String paymentId,
    required double amount,
    required DateTime paymentDate,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String? notes,
  }) {
    final now = DateTime.now();
    return PaymentHistoryModel(
      id: const Uuid().v4(),
      uuid: const Uuid().v4(),
      paymentId: paymentId,
      amount: amount,
      paymentDate: paymentDate,
      paymentMethod: paymentMethod,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  PaymentHistoryModel copyWith({
    String? paymentId,
    double? amount,
    DateTime? paymentDate,
    PaymentMethod? paymentMethod,
    String? notes,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return PaymentHistoryModel(
      id: id,
      uuid: uuid,
      paymentId: paymentId ?? this.paymentId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
