import 'package:flutter/cupertino.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class NotesService {
  Database? _db;
Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) async {
  final db = _getDatabaseOrThrow();
  await getNote(id: note.id);
  final updatesCount = await db.update(noteTable, {textColumn: text, isSyncedWithServerColumn: 0});

  if (updatesCount == 0) {
    throw CouldNotUpdateNote();
  }
  else{
    return await getNote(id: note.id);
  }

}

Future<Iterable<DatabaseNote>> getAllNotes({required int id}) async {
  final db = _getDatabaseOrThrow();
  final notes = await db.query(noteTable);
  return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
}

Future<DatabaseNote> getNote({required int id}) async {
  final db = _getDatabaseOrThrow();
  final notes = await db.query(noteTable, where: 'id = ?', whereArgs: [id]);
  if(notes.isEmpty) {
    throw CouldNotFindNote();
  }else{
    return DatabaseNote.fromRow(notes.first);
  }
}

Future<int> deleteAllNotes() async {
  final db = _getDatabaseOrThrow();
  return await db.delete(noteTable);
}
Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(noteTable, where: 'id = ?', whereArgs: [id]); 
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    }
    
  }

Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
  final db = _getDatabaseOrThrow();
  // Make sure owner exists in the database.
  final dbUser = await getUser(email: owner.email);
  if(dbUser != owner){
    throw CouldNotFindUser();
  }
  // Create the note.
  const text = '';
  final noteId = await db.insert(noteTable, {
    userIdColumn: owner.id,
    textColumn: text,
    isSyncedWithServerColumn: 1,
  });
  final note = DatabaseNote(id: noteId, text: text, userId: owner.id, isSyncedWithServer: true);
  return note;
}

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable, limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if(results.isEmpty){
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }
  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable, limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if(results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email,}) async {
    final db = _getDatabaseOrThrow(); 
    final deletedCount = await db.delete('userTable', where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if(deletedCount != 1) throw Exception('Unable to delete user');
  }
  Database _getDatabaseOrThrow() {
    final  db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }


  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    }
    else {
      await db.close();
      _db = null;

    }
  }
  Future<void> open() async {
    if(_db != null){
      throw DatabaseAlreadyOpenException();
    }
    try{
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // Create user tabel if it doesn't exist.
      await db.execute(createUserTable);
      // create note table if it doesn't exist.
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map) : id = map[idColumn] as int , email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, Email = $email';

  @override bool operator ==(covariant DatabaseUser other) => id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  

}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithServer;

  const DatabaseNote({required this.id, required this.userId, required this.text, required this.isSyncedWithServer});
  DatabaseNote.fromRow(
    Map<String, Object?> map) : id = map[idColumn] as int,
    userId = map[userIdColumn] as int, 
    text = map[textColumn] as String, 
    isSyncedWithServer = (map[isSyncedWithServerColumn] as int) == 1 ? true : false;


    @override
  String toString() => 
  'Note, ID = $id, userId = $userId, text = $text, IsSyncedWithServer = $isSyncedWithServer';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithServerColumn = 'is_synced_with_server';
const createUserTable = '''
      CREATE TABLE IF NOT EXISTS "user" (
        "id" INTEGER PRIMARY KEY,
        "email" TEXT NOT NULL UNIQUE,
      );
      ''';
const createNoteTable = '''
      CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_with_server"	INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';