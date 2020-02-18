import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_match/screen/createVideo.dart';
import 'package:video_match/utils/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Match',
      theme: ThemeData(
          appBarTheme: AppBarTheme(color: Colors.white),
          sliderTheme: SliderThemeData(
              activeTrackColor: mainColor,
              inactiveTrackColor: secondaryColor,
              thumbColor: Colors.white),
          floatingActionButtonTheme:
              FloatingActionButtonThemeData(backgroundColor: mainColor)),
      home: CreateVideoScreen(),
    );
  }
}
