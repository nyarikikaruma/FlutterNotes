import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class NotesService {
  Database? _db;

List<DatabaseNote> _notes = [];

static final NotesService _shared = NotesService._sharedInstance();
NotesService._sharedInstance(){
  _notesStreanController = StreamController<List<DatabaseNote>>.broadcast(
    onListen: () {
      _notesStreanController.sink.add(_notes);
    }
  );
}
factory NotesService() => _shared;

late final StreamController<List<DatabaseNote>> _notesStreanController;

Stream<List<DatabaseNote>> get allNotes => _notesStreanController.stream;

Future<DatabaseUser> getOrCreateUser(String email) async {
  try{
  final user= await getUser(email: email );
  return user;
  } on CouldNotFindUser {
    final createdUser = await createUser(email: email);
    return createdUser;
  } 
  catch (e) {
    rethrow;
  }
}

Future<void> _cacheNotes() async {
  final allNotes = await getAllNotes();
  _notes = allNotes.toList();
  _notesStreanController.add(_notes);
}

Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) async {
  await _ensureDbIsOpen();
  final db = _getDatabaseOrThrow();
  // Make sure note exists.
  await getNote(id: note.id);
  // Update DB.
  final updatesCount = await db.update(noteTable, {textColumn: text, isSyncedWithServerColumn: 0});

  if (updatesCount == 0) {
    throw CouldNotUpdateNote();
  }
  else{
    final updatedNote = await getNote(id: note.id);
    _notes.removeWhere((note) => note.id == updatedNote.id);
    _notes.add(updatedNote);
    _notesStreanController.add(_notes);
    return updatedNote;
  }

}

Future<Iterable<DatabaseNote>> getAllNotes() async {
  await _ensureDbIsOpen();
  final db = _getDatabaseOrThrow();
  final notes = await db.query(noteTable);
  return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
}

Future<DatabaseNote> getNote({required int id}) async {
  await _ensureDbIsOpen();
  final db = _getDatabaseOrThrow();
  final notes = await db.query(noteTable, where: 'id = ?', whereArgs: [id]);
  if(notes.isEmpty) {
    throw CouldNotFindNote();
  }else{
    final note = DatabaseNote.fromRow(notes.first);
    _notes.removeWhere((note) => note.id == id);
    _notes.add(note);
    _notesStreanController.add(_notes);
    return note;
  }
}

Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
  final db = _getDatabaseOrThrow();

  final numberOfDeletions = await db.delete(noteTable);
  _notes.clear();
  _notesStreanController.add(_notes);
  return numberOfDeletions;
}
Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(noteTable, where: 'id = ?', whereArgs: [id]); 
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    }
    else{
      _notes.removeWhere((note) => note.id == id);
      _notesStreanController.add(_notes);
    }
    
  }

Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
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
  // Add note to cache.
  _notes.add(note);
  _notesStreanController.add(_notes);
  return note;
}

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable, limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if(results.isEmpty){
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }
  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
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
    await _ensureDbIsOpen();
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
  
  Future<void> _ensureDbIsOpen() async{
    try {
      await open();
    
    } on DatabaseAlreadyOpenException{
      // Do nothing.
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
      await _cacheNotes();
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
      CREATE TABLE IF NOT EXISTS 'user' (
        'id' INTEGER PRIMARY KEY,
        'email' TEXT NOT NULL UNIQUE
      );
      ''';
const createNoteTable = '''
      CREATE TABLE IF NOT EXISTS 'note'(
        'id'	INTEGER NOT NULL,
        'user_id'	INTEGER NOT NULL,
        'text'	TEXT,
        'is_synced_with_server'	INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY(id AUTOINCREMENT)
      );''';