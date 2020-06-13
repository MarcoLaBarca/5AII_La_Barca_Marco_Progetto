import 'package:flutter/material.dart';
import 'package:password_safe/screen/loading_screen.dart';

void main() => runApp(MyApp());
final routes = {
  '/': (BuildContext context) => Loading(),
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyPassword',
      color: Colors.blue,
      initialRoute: '/',
      routes: routes,
    );
  }
}
