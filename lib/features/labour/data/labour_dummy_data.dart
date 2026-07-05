// ─── Enums ────────────────────────────────────────────────────────────────────

enum LabourRole { mason, carpenter, painter, electrician, plumber, helper, siteSupervisor }
enum LabourStatus { active, inactive }
enum AttendanceStatus { present, halfDay, absent }
enum PaymentMethod { cash, bankTransfer, upi }

// ─── Models ───────────────────────────────────────────────────────────────────

class LabourModel {
  const LabourModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.dailyWage,
    required this.status,
    required this.joinedDate,
    required this.address,
  });

  final String id;
  final String name;
  final String phone;
  final LabourRole role;
  final double dailyWage;
  final LabourStatus status;
  final DateTime joinedDate;
  final String address;

  String get initials {
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
  }

  String get formattedWage => '₹ ${dailyWage.toStringAsFixed(0)}/day';
}

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.labourId,
    required this.date,
    required this.status,
    this.overtimeHours = 0,
  });

  final String id;
  final String labourId;
  final DateTime date;
  final AttendanceStatus status;
  final double overtimeHours;
}

class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.labourId,
    required this.date,
    required this.amount,
    required this.method,
    this.notes,
  });

  final String id;
  final String labourId;
  final DateTime date;
  final double amount;
  final PaymentMethod method;
  final String? notes;
}

// ─── Dummy Data ───────────────────────────────────────────────────────────────

class LabourDummyData {
  const LabourDummyData._();

  static const roleLabels = {
    LabourRole.mason: 'Mason',
    LabourRole.carpenter: 'Carpenter',
    LabourRole.painter: 'Painter',
    LabourRole.electrician: 'Electrician',
    LabourRole.plumber: 'Plumber',
    LabourRole.helper: 'Helper',
    LabourRole.siteSupervisor: 'Site Supervisor',
  };

  static const statusLabels = {
    LabourStatus.active: 'Active',
    LabourStatus.inactive: 'Inactive',
  };

  static final List<LabourModel> workers = [
    LabourModel(
      id: 'l1',
      name: 'Ramesh Kumar',
      phone: '9876543210',
      role: LabourRole.mason,
      dailyWage: 800,
      status: LabourStatus.active,
      joinedDate: DateTime(2025, 1, 15),
      address: 'Andheri West, Mumbai',
    ),
    LabourModel(
      id: 'l2',
      name: 'Suresh Singh',
      phone: '9876543211',
      role: LabourRole.carpenter,
      dailyWage: 900,
      status: LabourStatus.active,
      joinedDate: DateTime(2025, 3, 10),
      address: 'Borivali East, Mumbai',
    ),
    LabourModel(
      id: 'l3',
      name: 'Amit Patel',
      phone: '9876543212',
      role: LabourRole.electrician,
      dailyWage: 1000,
      status: LabourStatus.active,
      joinedDate: DateTime(2025, 6, 20),
      address: 'Goregaon, Mumbai',
    ),
    LabourModel(
      id: 'l4',
      name: 'Rahul Sharma',
      phone: '9876543213',
      role: LabourRole.helper,
      dailyWage: 500,
      status: LabourStatus.active,
      joinedDate: DateTime(2026, 1, 5),
      address: 'Dharavi, Mumbai',
    ),
    LabourModel(
      id: 'l5',
      name: 'Vikash Yadav',
      phone: '9876543214',
      role: LabourRole.helper,
      dailyWage: 500,
      status: LabourStatus.inactive,
      joinedDate: DateTime(2025, 11, 12),
      address: 'Sion, Mumbai',
    ),
    LabourModel(
      id: 'l6',
      name: 'Mohammed Ali',
      phone: '9876543215',
      role: LabourRole.plumber,
      dailyWage: 950,
      status: LabourStatus.active,
      joinedDate: DateTime(2026, 2, 1),
      address: 'Kurla, Mumbai',
    ),
  ];

  static final List<AttendanceRecord> attendanceHistory = [
    AttendanceRecord(id: 'a1', labourId: 'l1', date: DateTime(2026, 7, 3), status: AttendanceStatus.present, overtimeHours: 2),
    AttendanceRecord(id: 'a2', labourId: 'l1', date: DateTime(2026, 7, 2), status: AttendanceStatus.present),
    AttendanceRecord(id: 'a3', labourId: 'l1', date: DateTime(2026, 7, 1), status: AttendanceStatus.halfDay),
    AttendanceRecord(id: 'a4', labourId: 'l2', date: DateTime(2026, 7, 3), status: AttendanceStatus.present),
    AttendanceRecord(id: 'a5', labourId: 'l2', date: DateTime(2026, 7, 2), status: AttendanceStatus.absent),
    AttendanceRecord(id: 'a6', labourId: 'l4', date: DateTime(2026, 7, 3), status: AttendanceStatus.present, overtimeHours: 4),
    AttendanceRecord(id: 'a7', labourId: 'l4', date: DateTime(2026, 7, 2), status: AttendanceStatus.present),
  ];

  static final List<PaymentRecord> paymentsHistory = [
    PaymentRecord(id: 'pay1', labourId: 'l1', date: DateTime(2026, 6, 30), amount: 5600, method: PaymentMethod.cash, notes: 'Weekly clearing'),
    PaymentRecord(id: 'pay2', labourId: 'l1', date: DateTime(2026, 6, 23), amount: 4800, method: PaymentMethod.upi, notes: 'Includes OT'),
    PaymentRecord(id: 'pay3', labourId: 'l2', date: DateTime(2026, 6, 30), amount: 6300, method: PaymentMethod.bankTransfer, notes: 'Weekly clearing'),
    PaymentRecord(id: 'pay4', labourId: 'l4', date: DateTime(2026, 6, 30), amount: 3500, method: PaymentMethod.cash),
  ];
}
