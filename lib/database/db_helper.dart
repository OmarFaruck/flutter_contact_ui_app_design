import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/contact_model.dart';

class DBHelper {

  // Singleton Object
  DBHelper._();

  static final DBHelper instance = DBHelper._();

  Database? _database;

  // Get Database
  Future<Database> get database async {

    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  // Initialize Database
  Future<Database> _initDatabase() async {

    String databasePath = await getDatabasesPath();

    String path = join(databasePath, 'contact_database.db');

    return await openDatabase(
      path,
      version: 1,

      onCreate: (db, version) async {

        await db.execute('''
          CREATE TABLE contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT NOT NULL,
            address TEXT NOT NULL,
            is_favorite INTEGER DEFAULT 0
          )
        ''');

      },
    );
  }

  // INSERT CONTACT
  Future<int> insertContact(Contact contact) async {

    final db = await database;

    return await db.insert(
      'contacts',
      contact.toMap(),
    );
  }

  // GET ALL CONTACTS + SEARCH + FAVORITE FILTER
  Future<List<Contact>> getContacts({
    String search = '',
    bool favoritesOnly = false,
  }) async {

    final db = await database;

    String where = '';
    List<dynamic> whereArgs = [];

    if (search.isNotEmpty) {
      where = 'name LIKE ?';
      whereArgs.add('%$search%');
    }

    if (favoritesOnly) {
      if (where.isNotEmpty) {
        where += ' AND ';
      }

      where += 'is_favorite = ?';
      whereArgs.add(1);
    }

    final result = await db.query(
      'contacts',
      where: where.isEmpty ? null : where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return result.map((e) => Contact.fromMap(e)).toList();
  }

  // UPDATE CONTACT
  Future<int> updateContact(Contact contact) async {

    final db = await database;

    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // DELETE CONTACT
  Future<int> deleteContact(int id) async {

    final db = await database;

    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // UPDATE FAVORITE STATUS
  Future<int> updateFavorite(int id, int value) async {

    final db = await database;

    return await db.update(
      'contacts',
      {'is_favorite': value},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}