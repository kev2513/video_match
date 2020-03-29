import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_match/utils/server/server.dart';
import 'package:video_match/utils/colors.dart';
import 'package:video_match/utils/ui/VMScaffold.dart';
import 'package:video_match/utils/ui/div.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return VMScaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: VMButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed("editVideo");
                  },
                  text: "Change your video",
                  size: 20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: VMButton(
                  onPressed: () {
                    TextEditingController textEditingController =
                        TextEditingController();
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  TextField(
                                    controller: textEditingController,
                                    maxLength: 2000,
                                    maxLines: 5,
                                    minLines: 3,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Please enter your idears'),
                                  ),
                                  FlatButton(
                                    onPressed: () async {
                                      showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (_) => WillPopScope(
                                                onWillPop: () async => false,
                                                child: AlertDialog(
                                                  title: Text(
                                                    "Thanks for your feedback!",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  content: VMLoadingCircle(),
                                                ),
                                              ));
                                      if (textEditingController.text.isNotEmpty)
                                        await Server.instance.sendFeedback(
                                            textEditingController.text,
                                            ownUid: true);
                                      Future.delayed(Duration(seconds: 1), () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    child: Text(
                                      "Send",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    color: mainColor,
                                  ),
                                  Divider(),
                                  Text(
                                    "If we need to answer, we write you an E-Mail to the adresse you used to sign in with our Google account.",
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  )
                                ],
                              ),
                            ));
                  },
                  text: "Send feedback",
                  color: mainColor,
                  size: 20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: VMButton(
                  onPressed: () {
                    TextEditingController textEditingController =
                        TextEditingController();
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              title: Text(
                                "Please enter why you want to delete your profile so that we can make our app better.\n\nTHIS CAN NOT BE UNDONE!",
                                style: TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  TextField(
                                    controller: textEditingController,
                                    maxLength: 400,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Please enter your reason'),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      FlatButton(
                                        onPressed: () async {
                                          if (textEditingController
                                              .text.isNotEmpty)
                                            await Server.instance.sendFeedback(
                                                textEditingController.text);
                                          await Server.instance.deleteProfile();
                                          exit(0);
                                        },
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        color: Colors.red,
                                      ),
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "Cancle",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        color: mainColor,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ));
                  },
                  text: "Delete profile",
                  color: Colors.red,
                  size: 15,
                ),
              ),
              VMButton(
                text: "Privacy Policy",
                color: Colors.black,
                size: 15,
                onPressed: () {
                  launch("https://videomatch-2020.firebaseapp.com/pp.txt");
                },
              ),
              VMButton(
                text: "Terms & Conditions",
                color: Colors.black,
                size: 15,
                onPressed: () {
                  launch("https://videomatch-2020.firebaseapp.com/tc.txt");
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
