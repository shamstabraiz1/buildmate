import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('buildmate_v1.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath =
        (!kIsWeb &&
                (defaultTargetPlatform == TargetPlatform.android ||
                    defaultTargetPlatform == TargetPlatform.iOS))
            ? await getDatabasesPath()
            : (await getApplicationSupportDirectory()).path;

    final path = join(dbPath, filePath);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 7,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      ),
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // ── v1 → v2 ──────────────────────────────────────────────────────────────
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE expenses ADD COLUMN quantity REAL');
      await db.execute('ALTER TABLE expenses ADD COLUMN unit TEXT');
      await db.execute('ALTER TABLE expenses ADD COLUMN vendor TEXT');
      await db.execute(
        'ALTER TABLE expenses ADD COLUMN paymentMethod TEXT NOT NULL DEFAULT "Cash"',
      );
      await db.execute(
        'ALTER TABLE expenses ADD COLUMN status TEXT NOT NULL DEFAULT "Paid"',
      );
      await db.execute(
        'ALTER TABLE expenses ADD COLUMN expenseNumber TEXT NOT NULL DEFAULT ""',
      );
    }

    // ── v2 → v3 ──────────────────────────────────────────────────────────────
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE labours ADD COLUMN status TEXT NOT NULL DEFAULT "active"',
      );
      await db.execute('ALTER TABLE labours ADD COLUMN cnic TEXT');
      await db.execute('ALTER TABLE labours ADD COLUMN address TEXT');
      await db.execute('ALTER TABLE labours ADD COLUMN overtimeRate REAL');
      await db.execute('ALTER TABLE labours ADD COLUMN photoUrl TEXT');
      await db.execute(
        'ALTER TABLE labours ADD COLUMN emergencyContactName TEXT',
      );
      await db.execute(
        'ALTER TABLE labours ADD COLUMN emergencyContactPhone TEXT',
      );
      await db.execute(
        'ALTER TABLE attendance ADD COLUMN overtimeHours REAL NOT NULL DEFAULT 0.0',
      );
    }

    // ── v3 → v4 ──────────────────────────────────────────────────────────────
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE labours ADD COLUMN imagePath TEXT');
      await db.execute('ALTER TABLE labours ADD COLUMN customRole TEXT');
      await db.execute('ALTER TABLE labours ADD COLUMN notes TEXT');
    }

    // ── v4 → v5  (Phase 4 – Materials Management) ────────────────────────────
    if (oldVersion < 5) {
      // Extend materials table
      await db.execute(
        'ALTER TABLE materials ADD COLUMN materialNumber TEXT NOT NULL DEFAULT ""',
      );
      await db.execute(
        'ALTER TABLE materials ADD COLUMN category TEXT NOT NULL DEFAULT "other"',
      );
      await db.execute('ALTER TABLE materials ADD COLUMN customCategory TEXT');
      await db.execute(
        'ALTER TABLE materials ADD COLUMN quantityPurchased REAL NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE materials ADD COLUMN quantityUsed REAL NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE materials ADD COLUMN reorderLevel REAL NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE materials ADD COLUMN status TEXT NOT NULL DEFAULT "available"',
      );
      await db.execute('ALTER TABLE materials ADD COLUMN imagePath TEXT');
      await db.execute('ALTER TABLE materials ADD COLUMN notes TEXT');

      // Extend vendors table
      await db.execute(
        'ALTER TABLE vendors ADD COLUMN rating REAL NOT NULL DEFAULT 0',
      );
      await db.execute('ALTER TABLE vendors ADD COLUMN notes TEXT');

      // Create material_transactions table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS material_transactions (
          id         TEXT PRIMARY KEY,
          uuid       TEXT NOT NULL,
          materialId TEXT NOT NULL,
          projectId  TEXT NOT NULL,
          vendorId   TEXT,
          type       TEXT NOT NULL,
          quantity   REAL NOT NULL,
          unitPrice  REAL,
          date       TEXT NOT NULL,
          notes      TEXT,
          createdAt  TEXT NOT NULL,
          updatedAt  TEXT NOT NULL,
          isDeleted  INTEGER NOT NULL DEFAULT 0
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_mat_txn_materialId ON material_transactions(materialId)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_mat_txn_projectId ON material_transactions(projectId)',
      );
    }

    // ── v5 → v6  (Phase 5 – Payments Management) ─────────────────────────────
    if (oldVersion < 6) {
      // Extend expenses table
      await db.execute(
        'ALTER TABLE expenses ADD COLUMN paidAmount REAL NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE expenses ADD COLUMN remainingBalance REAL NOT NULL DEFAULT 0',
      );

      // Extend existing payments table
      await db.execute(
        'ALTER TABLE payments ADD COLUMN paymentNumber TEXT NOT NULL DEFAULT ""',
      );
      await db.execute(
        'ALTER TABLE payments ADD COLUMN paidAmount REAL NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE payments ADD COLUMN remainingBalance REAL NOT NULL DEFAULT 0',
      );
      await db.execute('ALTER TABLE payments ADD COLUMN dueDate TEXT');
      await db.execute(
        'ALTER TABLE payments ADD COLUMN status TEXT NOT NULL DEFAULT "Pending"',
      );
      await db.execute('ALTER TABLE payments ADD COLUMN invoiceNumber TEXT');
      await db.execute('ALTER TABLE payments ADD COLUMN receiptPath TEXT');
      await db.execute('ALTER TABLE payments ADD COLUMN notes TEXT');
      await db.execute('ALTER TABLE payments ADD COLUMN installments TEXT');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_pay_projectId ON payments(projectId)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_pay_payeeId ON payments(payeeId)',
      );
    }

    // ── v6 → v7  (Phase 7 – Payment History) ─────────────────────────────────
    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS payment_history (
          id            TEXT PRIMARY KEY,
          uuid          TEXT NOT NULL,
          paymentId     TEXT NOT NULL,
          amount        REAL NOT NULL,
          paymentDate   TEXT NOT NULL,
          paymentMethod TEXT NOT NULL,
          notes         TEXT,
          createdAt     TEXT NOT NULL,
          updatedAt     TEXT NOT NULL,
          isDeleted     INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_payhist_paymentId ON payment_history(paymentId)',
      );
      // Note: We leave installments TEXT intact in the payments table to avoid data loss, 
      // but it will be gracefully ignored in the new architecture.
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';
    const textTypeNotNull = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL DEFAULT 0';
    const realType = 'REAL';

    // Standard metadata columns for all tables
    const standardColumns = '''
      uuid $textTypeNotNull,
      createdAt $textTypeNotNull,
      updatedAt $textTypeNotNull,
      isDeleted $boolType
    ''';

    // 1. Projects Table
    await db.execute('''
      CREATE TABLE projects (
        id $idType,
        name $textTypeNotNull,
        clientName $textTypeNotNull,
        location $textTypeNotNull,
        budget $realType NOT NULL,
        amountSpent $realType NOT NULL,
        progress $realType NOT NULL,
        status $textTypeNotNull,
        startDate $textTypeNotNull,
        endDate $textTypeNotNull,
        description $textTypeNotNull,
        $standardColumns
      )
    ''');

    // 2. Expenses Table
    await db.execute('''
      CREATE TABLE expenses (
        id $idType,
        projectId $textTypeNotNull,
        expenseNumber $textTypeNotNull,
        categoryId $textType,
        amount $realType NOT NULL,
        date $textTypeNotNull,
        quantity $realType,
        unit $textType,
        vendor $textType,
        paymentMethod $textTypeNotNull,
        status $textTypeNotNull,
        paidAmount $realType NOT NULL DEFAULT 0,
        remainingBalance $realType NOT NULL DEFAULT 0,
        notes $textType,
        receiptUrl $textType,
        $standardColumns
      )
    ''');

    // 3. Labours Table
    await db.execute('''
      CREATE TABLE labours (
        id $idType,
        name $textTypeNotNull,
        role $textTypeNotNull,
        dailyRate $realType NOT NULL,
        phone $textType,
        status $textTypeNotNull,
        cnic $textType,
        address $textType,
        overtimeRate $realType,
        imagePath $textType,
        customRole $textType,
        notes $textType,
        $standardColumns
      )
    ''');

    // 4. Attendance Table
    await db.execute('''
      CREATE TABLE attendance (
        id $idType,
        projectId $textTypeNotNull,
        labourId $textTypeNotNull,
        date $textTypeNotNull,
        status $textTypeNotNull,
        overtimeHours $realType NOT NULL,
        $standardColumns
      )
    ''');

    // 5. Materials Table (v5 — full schema)
    await db.execute('''
      CREATE TABLE materials (
        id               $idType,
        materialNumber   $textTypeNotNull,
        name             $textTypeNotNull,
        category         $textTypeNotNull,
        customCategory   $textType,
        projectId        $textType,
        vendorId         $textType,
        unit             $textTypeNotNull,
        unitPrice        $realType NOT NULL,
        quantityPurchased $realType NOT NULL DEFAULT 0,
        quantityUsed     $realType NOT NULL DEFAULT 0,
        reorderLevel     $realType NOT NULL DEFAULT 0,
        status           $textTypeNotNull,
        imagePath        $textType,
        notes            $textType,
        $standardColumns
      )
    ''');

    // 6. Material Transactions Table (v5 — new)
    await db.execute('''
      CREATE TABLE material_transactions (
        id         $idType,
        materialId $textTypeNotNull,
        projectId  $textTypeNotNull,
        vendorId   $textType,
        type       $textTypeNotNull,
        quantity   $realType NOT NULL,
        unitPrice  $realType,
        date       $textTypeNotNull,
        notes      $textType,
        $standardColumns
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_mat_txn_materialId ON material_transactions(materialId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_mat_txn_projectId ON material_transactions(projectId)',
    );

    // 7. Vendors Table (v5 — full schema)
    await db.execute('''
      CREATE TABLE vendors (
        id            $idType,
        name          $textTypeNotNull,
        contactPerson $textType,
        phone         $textType,
        email         $textType,
        address       $textType,
        rating        $realType NOT NULL DEFAULT 0,
        notes         $textType,
        $standardColumns
      )
    ''');

    // 8. Payments Table
    await db.execute('''
      CREATE TABLE payments (
        id              $idType,
        paymentNumber   $textTypeNotNull,
        projectId       $textTypeNotNull,
        payeeId         $textTypeNotNull,
        payeeType       $textTypeNotNull,
        amount          $realType NOT NULL,
        paidAmount      $realType NOT NULL DEFAULT 0,
        remainingBalance $realType NOT NULL DEFAULT 0,
        date            $textTypeNotNull,
        dueDate         $textType,
        paymentMethod   $textTypeNotNull,
        status          $textTypeNotNull,
        referenceNumber $textType,
        invoiceNumber   $textType,
        receiptPath     $textType,
        notes           $textType,
        installments    $textType,
        $standardColumns
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pay_projectId ON payments(projectId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pay_payeeId ON payments(payeeId)',
    );

    // 8.1 Payment History Table
    await db.execute('''
      CREATE TABLE payment_history (
        id            $idType,
        paymentId     $textTypeNotNull,
        amount        $realType NOT NULL,
        paymentDate   $textTypeNotNull,
        paymentMethod $textTypeNotNull,
        notes         $textType,
        $standardColumns
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_payhist_paymentId ON payment_history(paymentId)',
    );

    // 9. Settings Table
    await db.execute('''
      CREATE TABLE settings (
        id    $idType,
        key   $textTypeNotNull UNIQUE,
        value $textTypeNotNull,
        $standardColumns
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
