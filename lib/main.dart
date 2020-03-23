import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_match/screen/createProfile.dart';
import 'package:video_match/screen/editVideo.dart';
import 'package:video_match/screen/homeScreen.dart';
import 'package:video_match/screen/loginScreen.dart';
import 'package:video_match/screen/settingsScreen.dart';
import 'package:video_match/utils/background/worker.dart';
import 'package:video_match/utils/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AndroidAlarmManager.initialize();
  runApp(MyApp());
  //worker();
  AndroidAlarmManager.periodic(
    Duration(minutes: 1),
    0,
    workerOnceCaller,
    rescheduleOnReboot: true,
    wakeup: true,
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Match',
      theme: ThemeData(
          accentColor: secondaryColor,
          primaryColor: mainColor,
          canvasColor: Colors.white,
          textTheme: GoogleFonts.montserratTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: AppBarTheme(color: Colors.white, elevation: 0),
          sliderTheme: SliderThemeData(
              activeTrackColor: mainColor,
              inactiveTrackColor: secondaryColor,
              thumbColor: Colors.white),
          floatingActionButtonTheme:
              FloatingActionButtonThemeData(backgroundColor: mainColor)),
      routes: {
        '/': (context) => LoginScreen(),
        'homeScreen': (context) => HomeScreen(),
        'createProfile': (context) => CreateProfile(),
        'editVideo': (context) => EditVideo(),
        'settings': (context) => SettingsScreen(),
      },
    );
  }
}
