enum ExpenseCategory { fuel, food, travel, tools, permits, materials, misc }
enum PaymentMethod { cash, card, upi, bankTransfer }

class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.paymentMethod,
    this.projectId,
    this.notes,
    this.hasReceipt = false,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final PaymentMethod paymentMethod;
  final String? projectId;
  final String? notes;
  final bool hasReceipt;
}

class ExpensesDummyData {
  const ExpensesDummyData._();

  static const categoryLabels = {
    ExpenseCategory.fuel: 'Fuel & Transportation',
    ExpenseCategory.food: 'Food & Refreshments',
    ExpenseCategory.travel: 'Travel',
    ExpenseCategory.tools: 'Tools & Equipment',
    ExpenseCategory.permits: 'Permits & Fees',
    ExpenseCategory.materials: 'Misc Materials',
    ExpenseCategory.misc: 'Miscellaneous',
  };

  static const paymentMethodLabels = {
    PaymentMethod.cash: 'Cash',
    PaymentMethod.card: 'Credit/Debit Card',
    PaymentMethod.upi: 'UPI',
    PaymentMethod.bankTransfer: 'Bank Transfer',
  };

  static final List<ExpenseModel> expenses = [
    ExpenseModel(
      id: 'e1',
      title: 'Diesel for JCB',
      amount: 4500,
      date: DateTime(2026, 7, 4, 14, 30),
      category: ExpenseCategory.fuel,
      paymentMethod: PaymentMethod.card,
      projectId: 'p1',
      notes: 'Filled at HP Petrol Pump',
      hasReceipt: true,
    ),
    ExpenseModel(
      id: 'e2',
      title: 'Labour Lunch',
      amount: 1250,
      date: DateTime(2026, 7, 4, 13, 0),
      category: ExpenseCategory.food,
      paymentMethod: PaymentMethod.upi,
      projectId: 'p1',
      hasReceipt: true,
    ),
    ExpenseModel(
      id: 'e3',
      title: 'Site Safety Helmets',
      amount: 3200,
      date: DateTime(2026, 7, 3, 10, 15),
      category: ExpenseCategory.tools,
      paymentMethod: PaymentMethod.upi,
      projectId: 'p2',
      notes: '10 helmets from Hardware Store',
      hasReceipt: false,
    ),
    ExpenseModel(
      id: 'e4',
      title: 'Municipal Clearance Fee',
      amount: 15000,
      date: DateTime(2026, 7, 2, 11, 45),
      category: ExpenseCategory.permits,
      paymentMethod: PaymentMethod.bankTransfer,
      projectId: 'p3',
      notes: 'Ward office receipt pending',
      hasReceipt: false,
    ),
    ExpenseModel(
      id: 'e5',
      title: 'Temporary Wiring',
      amount: 2800,
      date: DateTime(2026, 7, 1, 16, 20),
      category: ExpenseCategory.materials,
      paymentMethod: PaymentMethod.cash,
      hasReceipt: true,
    ),
    ExpenseModel(
      id: 'e6',
      title: 'Supervisor Auto Fare',
      amount: 350,
      date: DateTime(2026, 7, 1, 9, 30),
      category: ExpenseCategory.travel,
      paymentMethod: PaymentMethod.cash,
      hasReceipt: false,
    ),
  ];
}
