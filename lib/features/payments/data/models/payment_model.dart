import 'package:uuid/uuid.dart';
import '../../../../core/utils/app_formatters.dart';

enum PaymentType { vendor, labour, expense, other }
enum PaymentStatus { paid, partial, pending, cancelled }
enum PaymentMethod { cash, bankTransfer, easyPaisa, jazzCash, cheque, other }

// PaymentInstallment has been replaced by PaymentHistoryModel
class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.uuid,
    required this.paymentNumber,
    required this.projectId,
    required this.payeeId,
    required this.paymentType,
    required this.amount,
    required this.paidAmount,
    required this.remainingBalance,
    required this.date,
    this.dueDate,
    this.paymentMethod = PaymentMethod.cash,
    required this.status,
    this.referenceNumber,
    this.invoiceNumber,
    this.receiptPath,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  final String id;
  final String uuid;
  final String paymentNumber; // PAY-YYYY-XXXX
  final String projectId;
  final String payeeId; // Reference to Vendor, Labour, or Expense
  final PaymentType paymentType;
  final double amount;
  final double paidAmount;
  final double remainingBalance;
  
  final DateTime date;
  final DateTime? dueDate;
  final PaymentMethod paymentMethod;
  final PaymentStatus status;

  final String? referenceNumber; // Bank tx ID, etc.
  final String? invoiceNumber; // Optional invoice number
  final String? receiptPath;
  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  String get formattedAmount => AppFormatters.currency(amount);
  String get formattedPaidAmount => AppFormatters.currency(paidAmount);
  String get formattedRemainingBalance => AppFormatters.currency(remainingBalance);
  String get formattedDate => AppFormatters.date(date);
  String? get formattedDueDate => dueDate != null ? AppFormatters.date(dueDate!) : null;

  static const typeLabels = {
    PaymentType.vendor: 'Vendor',
    PaymentType.labour: 'Labour',
    PaymentType.expense: 'Expense',
    PaymentType.other: 'Other',
  };

  static const statusLabels = {
    PaymentStatus.paid: 'Paid',
    PaymentStatus.partial: 'Partial',
    PaymentStatus.pending: 'Pending',
    PaymentStatus.cancelled: 'Cancelled',
  };

  static const methodLabels = {
    PaymentMethod.cash: 'Cash',
    PaymentMethod.bankTransfer: 'Bank Transfer',
    PaymentMethod.easyPaisa: 'EasyPaisa',
    PaymentMethod.jazzCash: 'JazzCash',
    PaymentMethod.cheque: 'Cheque',
    PaymentMethod.other: 'Other',
  };

  /// Auto-calculates paidAmount, remainingBalance, and status
  static PaymentModel calculateState(PaymentModel payment, double newPaid) {
    if (payment.status == PaymentStatus.cancelled) return payment;

    double newRemaining = payment.amount - newPaid;
    
    PaymentStatus newStatus;
    if (newRemaining <= 0) {
      newStatus = PaymentStatus.paid;
      newRemaining = 0; // prevent negative balance
    } else if (newPaid > 0) {
      newStatus = PaymentStatus.partial;
    } else {
      newStatus = PaymentStatus.pending;
    }

    return payment.copyWith(
      paidAmount: newPaid,
      remainingBalance: newRemaining,
      status: newStatus,
    );
  }

  factory PaymentModel.create({
    required String projectId,
    required String payeeId,
    required PaymentType paymentType,
    required double amount,
    required DateTime date,
    DateTime? dueDate,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String? referenceNumber,
    String? invoiceNumber,
    String? receiptPath,
    String? notes,
  }) {
    final now = DateTime.now();
    final uid = const Uuid().v4();
    final paymentNum = 'PAY-${now.year}-${uid.substring(0, 4).toUpperCase()}';
    
    final initialModel = PaymentModel(
      id: uid,
      uuid: uid,
      paymentNumber: paymentNum,
      projectId: projectId,
      payeeId: payeeId,
      paymentType: paymentType,
      amount: amount,
      paidAmount: 0,
      remainingBalance: amount,
      date: date,
      dueDate: dueDate,
      paymentMethod: paymentMethod,
      status: PaymentStatus.pending,
      referenceNumber: referenceNumber,
      invoiceNumber: invoiceNumber,
      receiptPath: receiptPath,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );

    return calculateState(initialModel, 0);
  }

  PaymentModel copyWith({
    String? projectId,
    String? payeeId,
    PaymentType? paymentType,
    double? amount,
    double? paidAmount,
    double? remainingBalance,
    DateTime? date,
    DateTime? dueDate,
    PaymentMethod? paymentMethod,
    PaymentStatus? status,
    String? referenceNumber,
    String? invoiceNumber,
    String? receiptPath,
    String? notes,
    bool? isDeleted,
  }) {
    return PaymentModel(
      id: id,
      uuid: uuid,
      paymentNumber: paymentNumber,
      projectId: projectId ?? this.projectId,
      payeeId: payeeId ?? this.payeeId,
      paymentType: paymentType ?? this.paymentType,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      receiptPath: receiptPath ?? this.receiptPath,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'paymentNumber': paymentNumber,
      'projectId': projectId,
      'payeeId': payeeId,
      'paymentType': paymentType.name,
      'amount': amount,
      'paidAmount': paidAmount,
      'remainingBalance': remainingBalance,
      'date': date.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'paymentMethod': paymentMethod.name,
      'status': status.name,
      'referenceNumber': referenceNumber,
      'invoiceNumber': invoiceNumber,
      'receiptPath': receiptPath,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] as String,
      uuid: map['uuid'] as String,
      paymentNumber: map['paymentNumber'] as String? ?? '',
      projectId: map['projectId'] as String,
      payeeId: map['payeeId'] as String,
      paymentType: PaymentType.values.firstWhere(
        (e) => e.name == map['paymentType'],
        orElse: () => PaymentType.other,
      ),
      amount: (map['amount'] as num).toDouble(),
      paidAmount: (map['paidAmount'] as num).toDouble(),
      remainingBalance: (map['remainingBalance'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PaymentStatus.pending,
      ),
      referenceNumber: map['referenceNumber'] as String?,
      invoiceNumber: map['invoiceNumber'] as String?,
      receiptPath: map['receiptPath'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }
}
