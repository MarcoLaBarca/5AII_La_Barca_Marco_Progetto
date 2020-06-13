import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:password_safe/data/database_helper.dart';
import 'package:password_safe/models/global.dart';
import 'package:password_safe/models/user.dart';
import 'package:password_safe/screen/password_screen.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

//Schermata di registrazione
class Registration extends StatefulWidget {
  final int id;
  Registration({this.id});

  _Registration createState() => _Registration();
}

class _Registration extends State<Registration> {
  String _password1 = '';
  String _password2 = '';
  int check;
  bool showPassword = false;
  bool showPassword2 = false;
  DatabaseHelper databaseHelper = DatabaseHelper();

//Assegnare il valore all'interno del TextField
  void onChangeU(String value) {
    setState(() {
      _password1 = value.trim();
    });
  }

//Assegnare il valore all'interno del TextField
  void onChangeP(String value) {
    setState(() {
      _password2 = value.trim();
    });
  }

//visibilità delle password nel momento dell'inserimento
  void visibility1(bool vis) {
    if (vis) {
      setState(() {
        showPassword = false;
      });
    } else {
      setState(() {
        showPassword = true;
      });
    }
  }
  void visibility2(bool vis) {
    if (vis) {
      setState(() {
        showPassword2 = false;
      });
    } else {
      setState(() {
        showPassword2 = true;
      });
    }
  }

//Tasto di registrazione che controlla se le passwords sono uguali e se l'utente
// si sta registrando o se sta modificando la password d'accesso
  void onPressedL() async {
    if (_password1 != _password2 || _password1.isEmpty) {
      if (_password1.isEmpty || _password1.isEmpty) {
        check = 1;
      } else {
        check = 2;
      }
      showDialog(
        context: context,
        builder: (_) => PassDiv(check),
      );
    } else {
      setState(() {
      key = _password1;
    });
      var passwordFin = utf8.encode(_password1); // è una codifica di caratteri Unicode in sequenze di lunghezza variabile di byte
      var digest = sha256.convert(passwordFin); //applico algoritmi sha2
      User user = User(digest.toString());
      if (widget.id != null) {
        user.id = widget.id;
        await databaseHelper.updateUser(user);
      } else {
        await databaseHelper.insertUser(user);
      }
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PasswordsScreen()));
    }
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      //Possibilità di tornare alla pagina precedente se è la prima registrazione o no
      onWillPop: () async {
        bool back;
        widget.id != null ? back = true : back = false;
        return back;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
              title: Text('MyPasswords'),
              //Vista della freccietta per tornare alla pagina precedente se è la prima registrazione o no
              leading: widget.id != null
                  ? IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : Container()),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                ListTile(
                  title: Text(
                    widget.id != null ? 'MODIFICA PASSWORD' : 'REGISTRAZIONE',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Text(
                    widget.id != null
                        ? 'Inserisci la nuova password'
                        : 'Effettua la registrazione inserendo la password e confermandola',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20.0),
                  margin: EdgeInsets.all(20.0),
                  alignment: Alignment.center,
                  height: 190,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextField(
                        onChanged: (String value) {
                          onChangeU(value);
                        },
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                            icon: Icon(Icons.vpn_key),
                            labelText: 'Insert your password',
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                              child: Icon(
                                showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              )),
                          ),
                      ),
                      Text(''),
                      TextField(
                        onChanged: (String value) {
                          onChangeP(value);
                        },
                        obscureText: !showPassword2,
                        decoration: InputDecoration(
                          icon: Icon(Icons.vpn_key),
                          labelText: 'Confirm password',
                          suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showPassword2 = !showPassword2;
                                });
                              },
                              child: Icon(
                                showPassword2
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),),
                        ),
                      ),
                    ],
                  ),
            ),
                SizedBox(height: 60),
                Container(
                  height: 50.0,
                  child: RaisedButton(
                    onPressed: () {
                      onPressedL();
                    },
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
                          widget.id != null ? "Salva modifiche" : "Registrati",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//Popup errore inserimento password
class PassDiv extends StatefulWidget {
  final int check;
  PassDiv(this.check);
  @override
  _PassDiv createState() => _PassDiv(check);
}

class _PassDiv extends State<PassDiv> {
  int check;
  String title;
  String sottotitle;
  _PassDiv(this.check);
  @override
  Widget build(BuildContext context) {
    switch (check) {
      case 1:
        {
          title = 'Campo password vuoto';
          sottotitle = 'Inserisci la password';
        }
        break;

      case 2:
        {
          title = 'Le password sono diverse';
          sottotitle = 'Controlla che le password siano uguali';
        }
        break;

      default:
        {
          print("Invalid choice");
        }
        break;
    }
    return AlertDialog(
      title: 
      RichText(
        text: TextSpan(
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19),
          children: [
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Icon(
                  Icons.warning,
                  color: Colors.white,
                ),
              ),
            ),
            TextSpan(text: title),
          ],
        ),
      ),
      content: Text(
        sottotitle,
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
      elevation: 30,
      backgroundColor: Colors.blue,
    );
  }
}
