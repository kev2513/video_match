import 'package:flutter/material.dart';
import 'package:video_match/screen/createVideo.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Match',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CreateVideoScreen(),
    );
  }
}
