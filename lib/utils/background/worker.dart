import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:video_match/utils/server/server.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationDetails platformChannelSpecifics;

Future<void> worker() async {
  List<String> likedUsers = List<String>();
  bool init = false;

  try {
    initNotifications();
    Server.instance.signIn().then((signedIn) {
      if (signedIn)
        Server.instance.likesProfileList().listen((data) async {
          if (init) {
            data.documents.forEach((document) async {
              if (!likedUsers.contains(document.documentID)) {
                likedUsers.add(document.documentID);
                await flutterLocalNotificationsPlugin.show(
                    Random.secure().nextInt(2000),
                    (Server.instance
                            .checkOwnUserLikedBack(document.documentID, true))
                        ? "Match!"
                        : "New like!",
                    "with " + document.data["name"],
                    platformChannelSpecifics,
                    payload: document.documentID);
              }
            });
          } else {
            data.documents.forEach((document) {
              likedUsers.add(document.documentID);
            });
            init = true;
          }
        });
    });
  } catch (e) {
    print(e.toString());
  }
}

initNotifications() async {
  var initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (payload) {
    print("PAYLOAD from app side: " + payload);
    return;
  });

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '0', 'Notifications', 'For chats, matches etc.');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
}
