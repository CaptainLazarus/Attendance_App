import 'db.dart';
import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static Database _db;
  static const String TABLE = 'subject';
  static const String ID = 'id';
  static const String NAME = 'name';
  static const String PRESENT = 'present';
  static const String ABSENT = 'absent';
  static const DB_NAME = 'subjects.db';

  Future<Database> get db async {
    if(_db != null) {
      return _db;
    }
    _db = await initDB();
    return _db;
  }

  initDB() async {
    io.Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path , DB_NAME);
    var db = await openDatabase(path , version: 1 , onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db , int version) async {
    await db.execute("CREATE TABLE  $TABLE ($ID INTEGER PRIMARY KEY , $NAME TEXT , $PRESENT INTEGER , $ABSENT INTEGER)");
  }

  Future<Subject> save(Subject subject) async {
    var database = await db;
    subject.id = await database.insert(TABLE, subject.toMap());
    return subject;
  }

  Future<List<Subject>> getSubjects() async {
    var database = await db;
    List<Map> maps = await database.query(TABLE , columns:[ID,NAME,PRESENT,ABSENT]);
    List<Subject> subjects = [];
    if(maps.length > 0){
      for(int i=0 ; i<maps.length ; i++){
        subjects.add(Subject.fromMap(maps[i]));
        print(subjects[i].toString());
      }
    }
    return subjects;
  }

  Future<int> delete(int id) async {
    var database = await db;
    return await database.delete(TABLE , where:'$ID = ?' , whereArgs: [id]);
  }

  Future<int> update(Subject subject) async {
    var database = await db;
    return await database.update(TABLE, subject.toMap() , where: "$ID = ?" , whereArgs: [subject.id]);
  }

  Future close() async {
    var database = await db;
    database.close();
  }

}