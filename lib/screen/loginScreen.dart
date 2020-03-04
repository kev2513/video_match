import 'package:flutter/material.dart';
import 'package:video_match/utils/colors.dart';
import 'package:video_match/utils/ui/VMScaffold.dart';
import 'package:video_match/utils/ui/button.dart';
import 'package:video_match/server/server.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showSigninButton = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await Server.instance.checkIfSignedIn())
        Navigator.of(context).pushReplacementNamed("homeScreen");
      else
        setState(() {
          _showSigninButton = true;
        });
    });
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
            (_showSigninButton)
                ? RoundedButton(
                    text: "Sign in with Google",
                    color: secondaryColor,
                    onPressed: () async {
                      if (await Server.instance.handleSignIn()) {
                        if (await Server.instance.checkIfProfileCreated() ==
                            false)
                          Navigator.of(context)
                              .pushReplacementNamed("createProfile");
                        else
                          Navigator.of(context)
                              .pushReplacementNamed("homeScreen");
                      }
                    },
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
