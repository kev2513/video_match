import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:video_match/utils/server/server.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationDetails platformChannelSpecifics;

Future<void> worker() async {
  List<String> usersLiked = List<String>();
  bool init = false;

  try {
    initNotifications();
    Server.instance.signIn().then((signedIn) {
      if (signedIn) {
        Server.instance.likesProfileList().listen((dataLikedUser) async {
          if (init) {
            dataLikedUser.documents.forEach((documentLikedUser) async {
              if (!usersLiked.contains(documentLikedUser.documentID)) {
                bool likedBack = Server.instance
                    .checkOwnUserLikedBack(documentLikedUser.documentID, true);
                usersLiked.add(documentLikedUser.documentID);
                if (likedBack) chatMessageStream(documentLikedUser);
                showNotification(likedBack ? "Match!" : "New like!",
                    "with " + documentLikedUser.data["name"]);
              }
            });
          } else {
            init = true;
            dataLikedUser.documents.forEach((documentLikedUser) {
              usersLiked.add(documentLikedUser.documentID);
              if (Server.instance
                  .checkOwnUserLikedBack(documentLikedUser.documentID, true)) {
                chatMessageStream(documentLikedUser);
              }
            });
          }
        });
      }
    });
  } catch (e) {
    print(e.toString());
  }
}

chatMessageStream(DocumentSnapshot documentLikedUser) {
  bool chatInit = false;
  Server.instance.chatStream(documentLikedUser.documentID).listen((dataChat) {
    if (dataChat.documents.first.data["messages"].last.keys.first !=
            Server.instance.firebaseUser.uid.substring(0, 6) &&
        chatInit) {
      showNotification(documentLikedUser.data["name"],
          dataChat.documents.first.data["messages"].last["m"].toString());
    } else
      chatInit = true;
  });
}

showNotification(String title, String message) async {
  await flutterLocalNotificationsPlugin.show(
      Random.secure().nextInt(2000), title, message, platformChannelSpecifics,
      payload: null);
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
