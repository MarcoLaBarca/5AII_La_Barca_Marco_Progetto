
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:password_safe/data/database_helper.dart';
import 'package:password_safe/models/passwords.dart';
import 'package:password_safe/screen/password_screen.dart';
import 'package:url_launcher/url_launcher.dart';

//schermata per inserire o aggiornare un set di password
class NewPassword extends StatefulWidget {
  final Password passwords;
  NewPassword(this.passwords);

  @override
  _NewPassword createState() => _NewPassword(this.passwords);
}

class _NewPassword extends State<NewPassword> {
  Password passwords;
  _NewPassword(this.passwords);

  DatabaseHelper databaseHelper = DatabaseHelper(); 
  TextEditingController passController = TextEditingController();
  TextEditingController nomeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  String pas;
  String no;
  String em;
  String us;
  String ur;
  int result;
  int check;
  String pass;
  //Controllo degli di inserimento campi obbligatori
  //Salvataggio o modifica dati sul db
  void _save() async {
    var uri = urlController.text;
    if (passwords.nome.isEmpty) {
      if (passwords.password.isEmpty) {
        //Campi password e nome vuoti
        check = 1;
        showDialog(
          context: context,
          builder: (_) => PassNomNull(check),
        );
      } else {
        //Campo nome vuoto
        check = 2;
        showDialog(
          context: context,
          builder: (_) => PassNomNull(check),
        );
      }
    } else {
      //Campo password vuoto
      if (passwords.password.isEmpty) {
        check = 3;
        showDialog(
          context: context,
          builder: (_) => PassNomNull(check),
        );
      } else {
        //Controllo se l'url è valido
        if (passwords.url.isNotEmpty) {
          if (await canLaunch(uri)) {
            if (passwords.id != null) {
              // Case 1: Update operation
              result = await databaseHelper.updatePasswords(passwords);
            } else {
              // Case 2: Insert Operation
              result = await databaseHelper.insertPasswors(passwords);
            }
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PasswordsScreen()));
          } else {
            check = 4;
            showDialog(
              context: context,
              builder: (_) => PassNomNull(check),
            );
          }
        } else {
          if (passwords.id != null) {
            // Case 1: Update operation
            result = await databaseHelper.updatePasswords(passwords);
          } else {
            // Case 2: Insert Operation
            result = await databaseHelper.insertPasswors(passwords);
          }
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PasswordsScreen()));
        }
      }
    }
  }

//assegnazione valori dei campi di inserimento
  void onChangeNome() {
    passwords.nome = nomeController.text.trim();
  }

  void onChangePass() {
    passwords.password = passController.text.trim();
  }

  void onChangeEmail() {
    passwords.email = emailController.text.trim();
  }

  void onChangeUser() {
    passwords.username = userController.text.trim();
  }

  void onChangeUrl() {
    passwords.url = urlController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    passController.text = passwords.password;
    nomeController.text = passwords.nome;
    emailController.text = passwords.email;
    userController.text = passwords.username;
    urlController.text = passwords.url;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('MyPasswords'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20.0),
            margin: EdgeInsets.all(20.0),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  passwords.id != null ? 'Modifica box' : "Crea una nuova box",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: nomeController,
                  onChanged: (value) {
                    onChangeNome();
                  },
                  decoration: InputDecoration(
                    suffixText: '*',
                    suffixStyle: TextStyle(
                      color: Colors.red,
                    ),
                    icon: Icon(Icons.create),
                    labelText: 'Inserisci il nome del sito',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: passController,
                  onChanged: (value) {
                    onChangePass();
                  },
                  decoration: InputDecoration(
                    suffixText: '*',
                    suffixStyle: TextStyle(
                      color: Colors.red,
                    ),
                    icon: Icon(Icons.vpn_key),
                    labelText: 'Inserisci la password',
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: emailController,
                  onChanged: (value) {
                    onChangeEmail();
                  },
                  decoration: InputDecoration(
                    icon: Icon(Icons.mail),
                    labelText: "Inserisci Email",
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: userController,
                  onChanged: (value) {
                    onChangeUser();
                  },
                  decoration: InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: "Inserisci Username",
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: urlController,
                  onChanged: (value) {
                    onChangeUrl();
                  },
                  decoration: InputDecoration(
                    icon: Icon(Icons.attach_file),
                    labelText: "Inserisci Url",
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                _save();
              });
            },
            child: Icon(Icons.add),
            tooltip: "Aggiungi set password"),
      ),
    );
  }
}

//alert errore campi obbligatori vuoti e correttenzza url
class PassNomNull extends StatefulWidget {
  final int check;
  PassNomNull(this.check);
  @override
  _PassNomNull createState() => _PassNomNull(check);
}

class _PassNomNull extends State<PassNomNull> {
  int check;
  String title;
  String sottotitle;

  _PassNomNull(this.check);
  @override
  Widget build(BuildContext context) {
    switch (check) {
      case 1:
        {
          title = 'Campi NOME e PASSWORD vuoti';
          sottotitle = 'Inserisci nome e password';
        }
        break;

      case 2:
        {
          title = 'Campo NOME vuoto';
          sottotitle = 'Inserisci un nome per identificare la tua password';
        }
        break;

      case 3:
        {
          title = 'Campo PASSWORD vuoto';
          sottotitle = 'Inserisci la password';
        }
        break;
      case 4:
        {
          title = 'URL non valido';
          sottotitle = 'Verifica la correttezza del link';
        }
        break;

      default:
        {
          print("Invalid choice");
        }
        break;
    }
    return AlertDialog(
      title: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
          children: [
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                ),
              ),
            ),
            TextSpan(
              text: '$title',
            ),
          ],
        ),
      ),
      content: Text(
        '$sottotitle',
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.left,
      ),
      elevation: 30,
      backgroundColor: Colors.blue,
    );
  }
}
