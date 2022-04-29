import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// database table and column names
const String tableNewWords = 'myNewWords';
const String columnId = '_id';
const String columnTitle = 'title';
const String columnBody = 'body';
const String columnImageUrl = 'image_url';
const String columnIsRead = 'is_read';
const String columnCreatedDate = 'created_date';

// data model class
class MyNewWords {

  int? id;
  String? title;

  MyNewWords();

  // convenience constructor to create a MyNewWords object
  MyNewWords.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    title = map[columnTitle];
  }

  // convenience method to create a Map from this MyNewWords object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTitle: title,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}

// singleton class to manage the database
class DatabaseHelper {

  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "myNewWords.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL string to create the database 
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableNewWords (
            $columnId INTEGER PRIMARY KEY,
            $columnTitle TEXT NOT NULL
          )
          ''');
  }

  Future<bool> removeTable() async {
    Database? db = await database;
    db!.delete(tableNewWords);
    return true;
  }
  // Database helper methods:

  Future<int> insert(MyNewWords word) async {
    Database? db = await database;
    int id = await db!.insert(tableNewWords, word.toMap());
    return id;
  }

  Future<MyNewWords?> queryWord(int id) async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableNewWords,
        columns: [columnId, columnTitle],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return MyNewWords.fromMap(maps.first);
    }
    return null;
  }

  Future<MyNewWords?> search(String? title) async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableNewWords,
        columns: [columnTitle],
        where: '$columnTitle = ?',
        whereArgs: [title]);
    if (maps.length > 0) {
      return MyNewWords.fromMap(maps.first);
    }
    return null;
  }
  Future<List<MyNewWords>> queryAll() async {
    Database? db = await database;
    List<MyNewWords> result = [];
    List<Map> maps = await db!.query(tableNewWords, columns: [columnId, columnTitle], orderBy: columnId);
    if (maps.length > 0) {
      for (var each in maps) {
        result.add(MyNewWords.fromMap(each));
      }
    }
    return new List.from(result.reversed);
  }

  Future<int> delete(int? id) async {
    Database? db = await database;
    int idDeleted = await db!.delete(tableNewWords, where: '$columnId = ?', whereArgs: [id]);
    return idDeleted;
  }

  Future<int> deleteWord(String word) async {
    Database? db = await database;
    int idDeleted = await db!.delete(tableNewWords, where: '$columnTitle = ?', whereArgs: [word]);
    return idDeleted;
  }


  Future<int> update(MyNewWords msg) async {
    Database? db = await database;
    int id = await db!.update(tableNewWords, msg.toMap(), where: '$columnId = ?', whereArgs: [msg.id]);
    return id;
  }
}