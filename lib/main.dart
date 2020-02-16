import 'package:flutter/material.dart';
import 'package:video_match/screen/createVideo.dart';
import 'package:video_match/utils/colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Match',
      theme: ThemeData(
        sliderTheme: SliderThemeData(activeTrackColor: mainColor, inactiveTrackColor: secondaryColor, thumbColor: Colors.white)
      ),
      home: CreateVideoScreen(),
    );
  }
}
