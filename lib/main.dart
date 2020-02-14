import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Match',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(body: Text("TEST")),
    );
  }
}
