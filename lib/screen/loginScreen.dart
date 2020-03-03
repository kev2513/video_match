import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:video_match/screen/homeScreen.dart';
import 'package:video_match/utils/colors.dart';
import 'package:video_match/utils/ui/button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }

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
              onPressed: () => _handleSignIn(),
            ),
          ],
        ),
      ),
    );
  }
}
