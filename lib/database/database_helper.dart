/// SQLite database helper — singleton with schema for users, attendance, and TA/DA entries.
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/attendance_entry.dart';
import '../models/tada_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('daily_attendance.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        employee_id TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        UNIQUE(user_id, date),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE tada_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        purpose TEXT NOT NULL,
        amount REAL NOT NULL,
        remarks TEXT DEFAULT '',
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Index for faster lookups by user and date range.
    await db.execute(
        'CREATE INDEX idx_attendance_user_date ON attendance(user_id, date)');
    await db.execute(
        'CREATE INDEX idx_tada_user_date ON tada_entries(user_id, date)');
  }

  // ─── User Operations ───

  Future<User> insertOrGetUser(String name, String employeeId) async {
    final db = await database;

    // Check if user already exists.
    final existing = await db.query(
      'users',
      where: 'employee_id = ?',
      whereArgs: [employeeId],
    );

    if (existing.isNotEmpty) {
      // Update name if changed.
      final user = User.fromMap(existing.first);
      if (user.name != name) {
        await db.update(
          'users',
          {'name': name},
          where: 'id = ?',
          whereArgs: [user.id],
        );
        return user.copyWith(name: name);
      }
      return user;
    }

    // Insert new user.
    final id = await db.insert('users', {
      'name': name,
      'employee_id': employeeId,
    });
    return User(id: id, name: name, employeeId: employeeId);
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  // ─── Attendance Operations ───

  Future<void> upsertAttendance(AttendanceEntry entry) async {
    final db = await database;
    await db.insert(
      'attendance',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AttendanceEntry>> getAttendanceForRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final startStr =
        '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endStr =
        '${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    final result = await db.query(
      'attendance',
      where: 'user_id = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, startStr, endStr],
      orderBy: 'date ASC',
    );
    return result.map((m) => AttendanceEntry.fromMap(m)).toList();
  }

  Future<AttendanceEntry?> getAttendanceForDate(
      int userId, DateTime date) async {
    final db = await database;
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final result = await db.query(
      'attendance',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateStr],
    );
    if (result.isEmpty) return null;
    return AttendanceEntry.fromMap(result.first);
  }

  // ─── TA/DA Operations ───

  Future<int> insertTadaEntry(TadaEntry entry) async {
    final db = await database;
    return db.insert('tada_entries', entry.toMap());
  }

  Future<void> updateTadaEntry(TadaEntry entry) async {
    final db = await database;
    await db.update(
      'tada_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteTadaEntry(int id) async {
    final db = await database;
    await db.delete('tada_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TadaEntry>> getTadaEntriesForDate(
      int userId, DateTime date) async {
    final db = await database;
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final result = await db.query(
      'tada_entries',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, dateStr],
      orderBy: 'id ASC',
    );
    return result.map((m) => TadaEntry.fromMap(m)).toList();
  }

  Future<List<TadaEntry>> getTadaEntriesForRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final startStr =
        '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endStr =
        '${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    final result = await db.query(
      'tada_entries',
      where: 'user_id = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, startStr, endStr],
      orderBy: 'date ASC, id ASC',
    );
    return result.map((m) => TadaEntry.fromMap(m)).toList();
  }
}
