import 'package:flutter/material.dart';
import 'package:password_safe/models/user.dart';
import 'package:password_safe/screen/registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

//schermata di loading iniziale
class Loading extends StatefulWidget {
  @override
  _Loading createState() => _Loading();
}

class _Loading extends State<Loading> {
  User user;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sp) {  //controllo se è la prima volta che apro l'applicazione
      if (sp.getBool('first_login') == null) {
        sp.setBool('first_login', false);
        //pagina del primo avvio
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Registration();
        }));
      } else {
        //pagina di login
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return HomePage();
        }));
      }
    });
  }

//caricamento della pagina finchè non trova se è il primo avvio o no
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
