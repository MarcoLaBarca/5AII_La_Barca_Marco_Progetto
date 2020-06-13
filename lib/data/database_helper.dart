import 'dart:io';
import 'package:password_safe/models/user.dart';
import 'package:password_safe/models/passwords.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:sqflite_sqlcipher/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; //singleton databaseHelper
  static Database _database; //singleton database

  String userTable = 'user';
  String colIdU = 'user_id';
  String colPasswordU = 'password';

  String passwordsTable = 'passwords';
  String colIdP = 'password_id';
  String colPasswordP = 'password';
  String colNomeP = 'nome';
  String colEmailP = 'email';
  String colUrlP = 'url';
  String colUserP = 'username';

  DatabaseHelper._createIstance();

//singleton costruttore per controllare se siste o no un dbhelper ed evitare errori
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createIstance();
    }
    return _databaseHelper;
  }

//Controllo se classe astratta db esiste, in caso contrario la creo
  Future<Database> get database async {
    if (_database == null) {
      _database = await initializedDataBase();
    }
    return _database;
  }


  Future<Database> initializedDataBase() async {
    //ottengo il percorso di dove si trova il db in locale
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path + 'Dati.db');
    //apro/creo db nel percorso ottenuto
    var pDB = await openDatabase(path, /* password: key */version: 1, onCreate: _createDb);
    return pDB;
  }

//creazione del db
  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $userTable($colIdU INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $colPasswordU TEXT)');
    await db.execute(
        'CREATE TABLE $passwordsTable($colIdP INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $colPasswordP BLOB, $colNomeP TEXT, $colEmailP TEXT, $colUrlP TEXT, $colUserP TEXT)');
  }

  //prendo tutte le passwords dal db
  Future<List<Map<String, dynamic>>> getPasswordsMapList() async {
    Database db = await this.database;
    var result = await db
        .rawQuery('SELECT * FROM $passwordsTable ORDER BY $colIdP DESC');
    return result;
  }

  //SELECT the 1 user
  Future<Map<String, dynamic>> selectFirstUser() async {
    Database db = await this.database;
    var result = await db.rawQuery('SELECT $colPasswordU FROM $userTable');
    //print(result);
    return result.first;
  }

  //SELECT user
  Future<List<Map<String, dynamic>>> selectUser(User user) async {
    Database db = await this.database;
    var result = await db.rawQuery(
        'SELECT $colPasswordU FROM $userTable WHERE $colIdU = \'${user.id}\'');
    return result;
  }

  //INSERT la password dell' user nel db
  Future<int> insertUser(User user) async {
    Database db = await this.database;
    var result = await db.rawInsert(
        'INSERT INTO $userTable($colPasswordU) VALUES(\'${user.password}\')');
    return result;
  }

  //INSERT password nel db
  Future<int> insertPasswors(Password passwords) async {
    Database db = await this.database;
    var result = await db.rawInsert(
        'INSERT INTO $passwordsTable($colPasswordP, $colNomeP, $colEmailP, $colUrlP, $colUserP)'
        'VALUES(\'${passwords.password}\', \'${passwords.nome}\', \'${passwords.email}\', \'${passwords.url}\', \'${passwords.username}\')');
    return result;
  }
  //UPDATE user
  Future<int> updateUser(User user) async {
    var db = await this.database;
    var result = await db.rawUpdate(
        'UPDATE $userTable SET $colPasswordU = \'${user.password}\' WHERE $colIdU = \'${user.id}\'');
    return result;
  }
  //UPDATE passwors row
  Future<int> updatePasswords(Password passwords) async {
    var db = await this.database;
    var result = await db.rawUpdate(
        'UPDATE $passwordsTable SET $colPasswordP = \'${passwords.password}\' , $colNomeP = \'${passwords.nome}\', $colEmailP = \'${passwords.email}\', $colUrlP = \'${passwords.url}\' ,$colUserP = \'${passwords.username}\' WHERE $colIdP = \'${passwords.id}\'');
    return result;
  }

  //DELETE passwords row
  Future<int> deletePasswords(int id) async {
    var db = await this.database;
    var result =
        await db.rawDelete('DELETE FROM $passwordsTable WHERE $colIdP = $id');
    return result;
  }

  //get the map List and convert in to Passswors Lists
  Future<List<Password>> getPasswordsList() async {
    var passworsMapList =
        await getPasswordsMapList(); //get map list from database
    int count =
        passworsMapList.length; //count the number of map entities in db table

    List<Password> passwordsList = List<Password>();
    //for loop per creare a password list da map List
    for (int i = 0; i < count; i++) {
      passwordsList.add(Password.fromMapObject(passworsMapList[i]));
    }
    return passwordsList;
  }
}