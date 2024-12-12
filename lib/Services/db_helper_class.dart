
import 'package:sqflite/sqflite.dart' as sql;

class DbHelperClass {
//..1  Table creation

  static Future<void> createTable(sql.Database database) async {
    await database.execute("""
    CREATE TABLE note (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      description TEXT,
      time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """);
  }

  //End

  // .. 2  Create a database...

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      "note_database.db",
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTable(database);
      },
    );
  }
  //End...

  // ..3 insert a new noteapp table

  static Future<int> createNote(String title, String description) async {
    final db = await DbHelperClass.db();
    final dataNote = {'title': title, 'description': description};
    return await db.insert(
      'note',
      dataNote,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }
  //End

  // ..4  get All notes

  static Future<List<Map<String, dynamic>>> getAllNotes() async {
    final db = await DbHelperClass.db();
    return db.query('note', orderBy: 'id DESC');
  }
  // End

  // .. 5 get single note

  static Future<List<Map<String, dynamic>>> getSingleNote(int id) async {
    final db = await DbHelperClass.db();
    return db.query('note', where: "id = ? ", whereArgs: [id], limit: 1);
  }

  //End

  // .. 6 updation

  static Future<int> updateNote(
    int id,
    String title,
    String? description,
  ) async {
    final db = await DbHelperClass.db();
    final dataNote = {
      'title': title,
      'description': description,
      'time': DateTime.now().toString(),
    };
    final result = await db.update('note', dataNote, where: "id = ? ", whereArgs: [id]);
    return result;
  }

  // End

  // .. 7 delete note

  static Future<void> deleteNote(int id) async {
    final db = await DbHelperClass.db();
    try {
      await db.delete('note', where: "id = ? ", whereArgs: [id]);
    } catch (e) {
      e.toString();
    }
  }
  // End

  // .. 8 delete all notes
  static Future<void> deleteAllnotes() async {
    final db = await DbHelperClass.db();
    try {
      await db.delete('note');
    } catch (e) {
      print(e.toString());
    }
  }

  // End

  // .. 9 total notes count
  static Future<int> totalNotesCount() async {
    final db = await DbHelperClass.db();

    try {
      final count = sql.Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT (*) FROM note'),
      );
      return count ?? 0;
    } catch (e) {
      print(
        e.toString(),
      );
      return 0;
    }
  }

  // End




  
}
