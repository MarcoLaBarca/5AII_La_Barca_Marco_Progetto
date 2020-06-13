import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:password_safe/data/database_helper.dart';
import 'package:password_safe/models/user.dart';
import 'dart:async';
import 'package:password_safe/screen/password_screen.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:password_safe/models/global.dart';

class HomePage extends StatefulWidget {
  _HomePage createState() => _HomePage();
} 

class _HomePage extends State<HomePage> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  String _passwordL = '';
  bool showPassword = false;
  DateTime backbuttonpressedTime;
  var singP;

  Future<bool> biometrics() async {
    final LocalAuthentication _localAuth = LocalAuthentication();
    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticateWithBiometrics(
          localizedReason: 'Scan Your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      showDialog(
        context: context,
        builder: (_) => ErrorFingerPrint(),
      );
      print(e);
    }
    return authenticated;
  }

  loginWithBio() async {
    bool login = false;
    try {
      login = await biometrics();
      if (login) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PasswordsScreen(),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  //pulsante login. Controllo digest password del db e digest password inserita
  void onPressedL() async {
    var passwordFin = utf8.encode(_passwordL); // data being hashed
    var digest = sha256.convert(passwordFin);
    String dig = digest.toString();
    String _passwordR =
        User.fromMapObject(await databaseHelper.selectFirstUser()).password;
    if (_passwordR == dig) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PasswordsScreen()));
    } else {
      showDialog(
        context: context,
        builder: (_) => PassDiv(),
      );
    }
  }

//assegnazione del valore del text field a varibile _passwordL
  void onChangeP(String value) {
    setState(() {
      _passwordL = value;
      key = _passwordL;
    });
  }

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
    } else {
      exit(0);
    }
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          title: Text('MyPasswords'),
        ),
        body: WillPopScope(
          onWillPop: onWillPop,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    "images/password-1104745.gif",
                  ),
                ),
                ListTile(
                  title: Text(
                    'LOGIN',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Text(
                    'Effettua il login per vedere le tue password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20.0),
                  margin: EdgeInsets.all(20.0),
                  alignment: Alignment.center,
                  height: 110,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextField(
                        onChanged: (String value) {
                          onChangeP(value);
                        },
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          icon: Icon(Icons.vpn_key),
                          labelText: 'Password login',
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
                    ],
                  ),
                ),
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
                          "Login",
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
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              loginWithBio();
            },
            child: Icon(Icons.fingerprint),
            tooltip: "Login con l'impronta digitale"),
      ),
    );
  }
}

//alert se la password è sbagliata
class PassDiv extends StatelessWidget {
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Password Errata',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19),
      ),
      content: Text(
        'Riprova ad inserire la password corretta',
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.left,
      ),
      elevation: 30,
      backgroundColor: Colors.blue,
    );
  }
}

//alert se l'impronta digitale non è supportata
class ErrorFingerPrint extends StatelessWidget {
  Widget build(BuildContext context) {
    return AlertDialog(
      title: RichText(
        text: TextSpan(
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19),
          children: [
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Icon(
                  Icons.block,
                  color: Colors.white,
                ),
              ),
            ),
            TextSpan(text: 'Impronta digitale non supportata'),
          ],
        ),
      ),
      content: Text(
        "Il tuo dispositivo non supporta l'impronta digitale",
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.left,
      ),
      elevation: 30,
      backgroundColor: Colors.blue,
    );
  }
}
