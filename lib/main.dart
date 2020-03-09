import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_match/screen/createProfile.dart';
import 'package:video_match/screen/createVideo.dart';
import 'package:video_match/screen/editVideo.dart';
import 'package:video_match/screen/homeScreen.dart';
import 'package:video_match/screen/loginScreen.dart';
import 'package:video_match/screen/settingsScreen.dart';
import 'package:video_match/utils/colors.dart';

String initialRoute;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Match',
      theme: ThemeData(
          accentColor: secondaryColor,
          primaryColor: mainColor,
          textTheme: GoogleFonts.montserratTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: AppBarTheme(color: Colors.white),
          sliderTheme: SliderThemeData(
              activeTrackColor: mainColor,
              inactiveTrackColor: secondaryColor,
              thumbColor: Colors.white),
          floatingActionButtonTheme:
              FloatingActionButtonThemeData(backgroundColor: mainColor)),
              initialRoute: initialRoute,
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
