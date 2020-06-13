import 'dart:io';
import 'package:password_safe/data/database_helper.dart';
import 'package:password_safe/models/passwords.dart';
import 'package:password_safe/models/user.dart';
import 'package:password_safe/screen/newPassword_screen.dart';
import 'package:flutter/material.dart';
import 'package:password_safe/screen/registration_screen.dart';
import 'package:password_safe/screen/setPassword_screen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fluttertoast/fluttertoast.dart';


class PasswordsScreen extends StatefulWidget {
  _Passwords createState() => _Passwords();
}

class _Passwords extends State<PasswordsScreen> {
  User user = User('');
  DatabaseHelper databaseHelper = DatabaseHelper();
  DateTime backbuttonpressedTime;
  List<Password> passwordsList;
  List<Password> filteredList;
  bool show = false;
  String string;
  String dec;
  String decc;

//Doppio tocco per uscire
   Future<bool> onWillPop() async {
     DateTime currentTime = DateTime.now();
    bool backButton = backbuttonpressedTime == null ||
        currentTime.difference(backbuttonpressedTime) > Duration(seconds: 2);
    if (backButton) {
      backbuttonpressedTime = currentTime;
      Fluttertoast.showToast(
        msg: "Tocca di nuovo per uscire",
        textColor: Colors.white,
        backgroundColor: Colors.blue,
      );
      return false;
      }else{
        exit(0);
      }
  } 

//Tocco della card per vedere i dati di una password
  void _onTap(Password passwords) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SetPassword(passwords);
    }));
  }

//aggiornamento della lista di passwords
  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializedDataBase();
    //.then è la callback che viene chiamata quando la variabile future ha un valore
    dbFuture.then((database) async {
      List<Password> passwordsList = await databaseHelper.getPasswordsList();
      setState(() {
        this.passwordsList = passwordsList;
        this.filteredList = passwordsList;
      });
    });
  }

//Nuova password
  void _addNewBox(Password password) async {
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NewPassword(password)));
    if (result == true) {
      updateListView();
    }
  }

//Filtro per ricerca delle passwords in base al nome
  void _filter(String value) {
    setState(() {
      filteredList = passwordsList
          .where((passwords) =>
              (passwords.nome.toLowerCase().contains(value.toLowerCase())))
          .toList();
    });
  }

//Per mostrare la barra di ricerca
  void _show() async {
    setState(() {
      show = true;
    });
  }

//per nascodere la barra di ricerca
  void _hide() async {
    setState(() {
      show = false;
      filteredList = passwordsList;
    });
  }

//per modificare la password d'accesso
  void passUser(int id) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Registration(
                  id: id,
                )));
  }

  Widget build(BuildContext context) {
    if (passwordsList == null) {
      passwordsList = List<Password>();
      updateListView();
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(title: Text('MyPasswords'), actions: <Widget>[
            IconButton(
              onPressed: () {
                _show();
              },
              icon: Icon(Icons.search),
            )
          ]),
          drawer: Drawer(
            child: Column(
              children: <Widget>[
                Container(
                  child: Text(
                    'IMPOSTAZIONI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 20,
                    ),
                  ),
                  margin: EdgeInsets.all(15),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  height: 50.0,
                  child: RaisedButton(
                    onPressed: () {
                      passUser(1);
                    },
                    elevation: 7,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80.0)),
                    padding: EdgeInsets.all(0.0),
                    child: Ink(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff374ABE), Color(0xff64B6FF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
                        alignment: Alignment.center,
                        child: Text(
                          "Cambia Password d'accesso",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Container(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          'Designed by @marcolabarca_',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        margin: EdgeInsets.all(20)),
                  ),
                )
              ],
            ),
          ),
          resizeToAvoidBottomPadding: false,
          body: WillPopScope(
            onWillPop: onWillPop,
            child: Container(
              child: Column(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _search(),
                ),
                Expanded(
                  child: _getBody(),
                )
              ]),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _addNewBox(Password(null, '', '', '', ''));
            },
            child: Icon(Icons.edit),
            tooltip: "Scrivi una nuova password"
          ),
        ),
      ),
    );
  }

//Barra di ricerca
  Widget _search() {
    return Visibility(
      child: TextField(
        onChanged: (value) {
          _filter(value);
        },
        autofocus: true,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            labelText: "Cerca",
            prefixIcon: Icon(Icons.search),
            contentPadding: EdgeInsets.all(15.0),
            hintText: 'Inserisci il nome',
            suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _hide();
                })),
      ),
      visible: show,
    );
  }
//Creazione dinamica della pagina con tutte le passwords
  Widget _getBody() {
    return FutureBuilder(
        future: databaseHelper.getPasswordsMapList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> rawPasswords = snapshot.data;
            List<Password> passwords =
                (rawPasswords.map((e) => Password.fromMapObject(e)).toList());
            return getPassListView(passwords);
          } else
            return CircularProgressIndicator();
        });
  }

  Widget getPassListView(List<Password> passwords) {
    if (filteredList != null)

      return ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (BuildContext context, int position) {
           
          return Card(
            elevation: 7,
            child: new InkWell(
              onTap: () {
                _onTap(filteredList[position]);
              },
              splashColor: Colors.blue,
              child: ListTile(
                title: Text(filteredList[position].nome),
                subtitle:
                Text(
                  filteredList[position].password,
                  style: TextStyle(fontSize: 16),
                ),
                leading: Icon(
                  Icons.vpn_key,
                  color: Colors.blue,
                ),
              ),
            ),
          );
        },
      );
    else
      return CircularProgressIndicator();
  }
}