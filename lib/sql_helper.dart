import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';

class SQLHelper {
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      join(await sql.getDatabasesPath(), 'diary.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE diaries(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            feeling TEXT,
            description TEXT,
            imagePath TEXT,
            createdAt TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  // Method to get all diaries
  static Future<List<Map<String, dynamic>>> getDiaries() async {
    final db = await SQLHelper.db();
    return db.query('diaries', orderBy: "id");
  }

  // Method to create a new diary
  static Future<void> createDiary(String feeling, String description, String? imagePath) async {
    final db = await SQLHelper.db();
    final data = {
      'feeling': feeling,
      'description': description,
      'imagePath': imagePath,
      'createdAt': DateTime.now().toString()
    };
    await db.insert('diaries', data);
  }

  // Method to update an existing diary
  static Future<void> updateDiary(int id, String feeling, String description, String? imagePath) async {
    final db = await SQLHelper.db();
    final data = {
      'feeling': feeling,
      'description': description,
      'imagePath': imagePath,
      'createdAt': DateTime.now().toString()
    };
    await db.update('diaries', data, where: 'id = ?', whereArgs: [id]);
  }

  // Method to delete a diary
  static Future<void> deleteDiary(int id) async {
    final db = await SQLHelper.db();
    await db.delete('diaries', where: 'id = ?', whereArgs: [id]);
  }

  // Method to delete all diaries
  static Future<void> deleteAllDiaries() async {
    final db = await SQLHelper.db();
    await db.delete('diaries');
  }
}
