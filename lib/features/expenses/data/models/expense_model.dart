import 'package:uuid/uuid.dart';
import '../../../../core/utils/app_formatters.dart';

enum ExpenseStatus { paid, pending, partiallyPaid }
enum PaymentMethod { cash, bankTransfer, easyPaisa, jazzCash, cheque, other }
enum ExpenseSortOption { newest, oldest, highestAmount, lowestAmount }

class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.uuid,
    required this.projectId,
    required this.expenseNumber,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.quantity,
    this.unit,
    this.vendor,
    this.paymentMethod = PaymentMethod.cash,
    this.status = ExpenseStatus.paid,
    this.notes,
    this.receiptUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  final String id;
  final String uuid;
  final String projectId;
  final String expenseNumber;
  final String categoryId; // Predefined or custom string
  final double amount;
  final DateTime date;
  
  final double? quantity;
  final String? unit;
  final String? vendor;
  final PaymentMethod paymentMethod;
  final ExpenseStatus status;
  final String? notes;
  final String? receiptUrl;

  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  String get formattedAmount => AppFormatters.currency(amount);
  String get formattedDate => AppFormatters.date(date);

  static const List<String> predefinedCategories = [
    'Labour', 'Cement', 'Steel', 'Bricks', 'Sand', 'Crush', 'Tiles', 
    'Paint', 'Electric', 'Plumbing', 'Wood', 'Glass', 'Doors & Windows', 
    'Machinery', 'Fuel', 'Transport', 'Water', 'Food', 'Rent', 'Miscellaneous'
  ];

  static const statusLabels = {
    ExpenseStatus.paid: 'Paid',
    ExpenseStatus.pending: 'Pending',
    ExpenseStatus.partiallyPaid: 'Partially Paid',
  };

  static const paymentMethodLabels = {
    PaymentMethod.cash: 'Cash',
    PaymentMethod.bankTransfer: 'Bank Transfer',
    PaymentMethod.easyPaisa: 'EasyPaisa',
    PaymentMethod.jazzCash: 'JazzCash',
    PaymentMethod.cheque: 'Cheque',
    PaymentMethod.other: 'Other',
  };

  factory ExpenseModel.create({
    required String projectId,
    required String categoryId,
    required double amount,
    required DateTime date,
    double? quantity,
    String? unit,
    String? vendor,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    ExpenseStatus status = ExpenseStatus.paid,
    String? notes,
    String? receiptUrl,
  }) {
    final now = DateTime.now();
    final uid = const Uuid().v4();
    // Generate expense number EXP-YYYY-XXXX (last 4 chars of uid)
    final expenseNum = 'EXP-${now.year}-${uid.substring(0, 4).toUpperCase()}';
    
    return ExpenseModel(
      id: uid,
      uuid: uid,
      projectId: projectId,
      expenseNumber: expenseNum,
      categoryId: categoryId,
      amount: amount,
      date: date,
      quantity: quantity,
      unit: unit,
      vendor: vendor,
      paymentMethod: paymentMethod,
      status: status,
      notes: notes,
      receiptUrl: receiptUrl,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }

  ExpenseModel copyWith({
    String? projectId,
    String? categoryId,
    double? amount,
    DateTime? date,
    double? quantity,
    String? unit,
    String? vendor,
    PaymentMethod? paymentMethod,
    ExpenseStatus? status,
    String? notes,
    String? receiptUrl,
    bool? isDeleted,
  }) {
    return ExpenseModel(
      id: id,
      uuid: uuid,
      projectId: projectId ?? this.projectId,
      expenseNumber: expenseNumber,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      vendor: vendor ?? this.vendor,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'projectId': projectId,
      'expenseNumber': expenseNumber,
      'categoryId': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'unit': unit,
      'vendor': vendor,
      'paymentMethod': paymentMethod.name,
      'status': status.name,
      'notes': notes,
      'receiptUrl': receiptUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      uuid: map['uuid'] as String,
      projectId: map['projectId'] as String,
      expenseNumber: map['expenseNumber'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      quantity: map['quantity'] != null ? (map['quantity'] as num).toDouble() : null,
      unit: map['unit'] as String?,
      vendor: map['vendor'] as String?,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      status: ExpenseStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ExpenseStatus.paid,
      ),
      notes: map['notes'] as String?,
      receiptUrl: map['receiptUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }
}
