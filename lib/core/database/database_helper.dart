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
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS))
        ? await getDatabasesPath()
        : (await getApplicationSupportDirectory()).path;
        
    final path = join(dbPath, filePath);

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      ),
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to expenses table
      await db.execute('ALTER TABLE expenses ADD COLUMN quantity REAL');
      await db.execute('ALTER TABLE expenses ADD COLUMN unit TEXT');
      await db.execute('ALTER TABLE expenses ADD COLUMN vendor TEXT');
      await db.execute('ALTER TABLE expenses ADD COLUMN paymentMethod TEXT NOT NULL DEFAULT "Cash"');
      await db.execute('ALTER TABLE expenses ADD COLUMN status TEXT NOT NULL DEFAULT "Paid"');
      await db.execute('ALTER TABLE expenses ADD COLUMN expenseNumber TEXT NOT NULL DEFAULT ""');
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
        $standardColumns
      )
    ''');

    // 5. Materials Table
    await db.execute('''
      CREATE TABLE materials (
        id $idType,
        projectId $textTypeNotNull,
        name $textTypeNotNull,
        quantity $realType NOT NULL,
        unit $textTypeNotNull,
        unitPrice $realType NOT NULL,
        vendorId $textType,
        $standardColumns
      )
    ''');

    // 6. Vendors Table
    await db.execute('''
      CREATE TABLE vendors (
        id $idType,
        name $textTypeNotNull,
        contactPerson $textType,
        phone $textType,
        email $textType,
        address $textType,
        $standardColumns
      )
    ''');

    // 7. Payments Table
    await db.execute('''
      CREATE TABLE payments (
        id $idType,
        projectId $textTypeNotNull,
        payeeId $textTypeNotNull,
        payeeType $textTypeNotNull,
        amount $realType NOT NULL,
        date $textTypeNotNull,
        paymentMethod $textTypeNotNull,
        referenceNumber $textType,
        $standardColumns
      )
    ''');

    // 8. Settings Table
    await db.execute('''
      CREATE TABLE settings (
        id $idType,
        key $textTypeNotNull UNIQUE,
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
