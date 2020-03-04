import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:video_match/screen/createProfile.dart';
import 'package:video_match/screen/homeScreen.dart';
import 'package:video_match/utils/colors.dart';
import 'package:video_match/utils/ui/button.dart';
import 'package:video_match/server/server.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return VMScaffold(
      colorfulBackground: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              "Welcome",
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
            CircleAvatar(
              child: Image.asset("assets/app_icon.png"),
              radius: 100,
              backgroundColor: Colors.grey[850],
            ),
            RoundedButton(
              text: "Sign in with Google",
              color: secondaryColor,
              onPressed: () async {
                if (await Server.instance.handleSignIn()) {
                  //TODO check if profile exists
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => CreateProfile()));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
