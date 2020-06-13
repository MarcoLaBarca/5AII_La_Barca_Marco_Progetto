import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:password_safe/data/database_helper.dart';
import 'package:password_safe/models/passwords.dart';
import 'package:password_safe/screen/password_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'newPassword_screen.dart';

//Schermata con dati di una password
class SetPassword extends StatefulWidget {
  final Password passwords;
  SetPassword(this.passwords);

  @override
  _SetPassword createState() => _SetPassword(this.passwords);
}

class _SetPassword extends State<SetPassword> {
  Password passwords;
  _SetPassword(this.passwords);

  DatabaseHelper databaseHelper = DatabaseHelper();

//pusante per modifica
  void onTapM(Password passwords) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => NewPassword(passwords)));
  }

//pulsante di eliminzazione di un set
  void onTapD() {
    showDialog(
      context: context,
      builder: (_) => CheckDelete(this.passwords),
    );
  }

  @override
  Widget build(BuildContext context) {
    String pass = passwords.password;
    String nome = passwords.nome;
    String email = passwords.email;
    String user = passwords.username;
    String url = passwords.url;
    var uri = url;

    bool ur = true;
    bool us = true;
    bool em = true;

    if (email.isEmpty) {
      em = false;
    }
    if (user.isEmpty) {
      us = false;
    }
    if (url.isEmpty) {
      ur = false;
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('MyPasswords'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: ListView(
          children: <Widget>[
            SizedBox(height: 30),
            Text(
              "I MIEI DATI",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            ListTile(
              title: Text(
                "NOME SITO",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              subtitle: SelectableText(
                nome,
                cursorColor: Colors.blue,
                showCursor: true,
                toolbarOptions: ToolbarOptions(
                    copy: true, selectAll: true, cut: false, paste: false),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              title: Text(
                "LA TUA PASSWORD",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              subtitle: SelectableText(
                pass,
                cursorColor: Colors.blue,
                showCursor: true,
                toolbarOptions: ToolbarOptions(
                    copy: true, selectAll: true, cut: false, paste: false),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            Visibility(
              child: ListTile(
                title: Text(
                  "LA TUA EMAIL",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                subtitle: SelectableText(
                  email,
                  cursorColor: Colors.blue,
                  showCursor: true,
                  toolbarOptions: ToolbarOptions(
                      copy: true, selectAll: true, cut: false, paste: false),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              visible: em,
            ),
            Visibility(
              child: ListTile(
                title: Text(
                  "IL TUO USERNAME",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                subtitle: SelectableText(
                  user,
                  cursorColor: Colors.blue,
                  showCursor: true,
                  toolbarOptions: ToolbarOptions(
                      copy: true, selectAll: true, cut: false, paste: false),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              visible: us,
            ),
            Visibility(
              child: ListTile(
                title: Text(
                  "URL",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                subtitle: InkWell(
                  child: Text(url, style: TextStyle(color: Colors.black),),
                  onTap: () {
                    launch(uri);
                  },
                ),
              ),
              visible: ur,
            ),
          ],
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          children: [
            SpeedDialChild(
              child: Icon(Icons.create),
              label: "Modifica",
              onTap: () {
                onTapM(passwords);
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.delete),
              label: "Elimina",
              onTap: () {
                onTapD();
              },
            )
          ],
        ),
      ),
    );
  }
}

//alert per decidere se eliminare o no i set
class CheckDelete extends StatefulWidget {
  final Password passwords;
  CheckDelete(this.passwords);

  @override
  _CheckDelete createState() => _CheckDelete(this.passwords);
}

class _CheckDelete extends State<CheckDelete> {
  final Password passwords;
  _CheckDelete(this.passwords);

  DatabaseHelper databaseHelper = DatabaseHelper();

  void _delete() async {
    await databaseHelper.deletePasswords(passwords.id);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PasswordsScreen()));
  }

  Widget build(BuildContext context) {
    return AlertDialog(
      title: RichText(
        text: TextSpan(
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
          children: [
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
            TextSpan(text: 'Elimina'),
          ],
        ),
      ),
      content: Text(
        'Sei sicuro di voler eliminare questi dati?',
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.left,
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "No",
              style: TextStyle(color: Colors.white),
            )),
        FlatButton(
            onPressed: () {
              _delete();
            },
            child: Text(
              "Si",
              style: TextStyle(color: Colors.white),
            )),
      ],
      elevation: 30,
      backgroundColor: Colors.blue,
    );
  }
}
