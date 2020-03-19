import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_match/screen/createVideo.dart';
import 'package:video_match/utils/server/server.dart';
import 'package:video_match/utils/ui/VMScaffold.dart';
import 'package:video_match/utils/ui/div.dart';

class EditVideo extends StatefulWidget {
  @override
  _EditVideoState createState() => _EditVideoState();
}

class _EditVideoState extends State<EditVideo> {
  bool videoCreated = false;
  @override
  Widget build(BuildContext context) {
    return VMScaffold(
      body: CreateVideo(
        onVideoCreated: () {
          setState(() {
            videoCreated = true;
          });
        },
        onVideoDeleted: () {
          setState(() {
            videoCreated = false;
          });
        },
      ),
      floatingActionButton: (videoCreated)
          ? FloatingActionButton(
              child: Icon(Icons.file_upload),
              onPressed: () async {
                loadingDialog(context);

                await Server.instance.saveProfile(userData: {
                  "image": Base64Codec()
                      .encode(await File(await getSelfiePath()).readAsBytes()),
                }, videoPath: await getSelfVideoPath());
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            )
          : Container(),
    );
  }
}
