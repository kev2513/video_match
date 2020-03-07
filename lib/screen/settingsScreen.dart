import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_match/server/server.dart';
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
      body: Column(
        children: <Widget>[
          VMButton(
            onPressed: () async {
              await Server.instance.deleteProfile();
              exit(0);
            },
            text: "Delete Profile",
            color: Colors.red,
            size: 15,
          )
        ],
      ),
    );
  }
}
