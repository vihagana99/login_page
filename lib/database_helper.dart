import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "user_data.db";
  static const _databaseVersion = 1;

  static const table = 'user_table';
  static const columnId = '_id';
  static const columnUserCode = 'User_Code';
  static const columnUserDisplayName = 'User_Display_Name';
  static const columnEmail = 'Email';
  static const columnUserEmployeeCode = 'User_Employee_Code';
  static const columnCompanyCode = 'Company_Code';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database and create the table if it doesn't exist
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // Create the table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnUserCode TEXT NOT NULL,
        $columnUserDisplayName TEXT NOT NULL,
        $columnEmail TEXT NOT NULL,
        $columnUserEmployeeCode TEXT NOT NULL,
        $columnCompanyCode TEXT NOT NULL
      )
    ''');
  }

  // Insert a new user into the database
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // Get all user records
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }
}
