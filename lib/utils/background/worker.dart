import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_match/utils/server/server.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationDetails platformChannelSpecifics;

Future<void> workerOnceCaller() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  DateTime prefsTime =
      DateTime.fromMillisecondsSinceEpoch(prefs.getInt("lastWork") ?? 0);
  if (DateTime.now().isAfter(prefsTime)) {
    worker();
    prefs.setInt("lastWork",
        DateTime.now().add(Duration(minutes: 2)).millisecondsSinceEpoch);
    Timer.periodic(Duration(seconds: 15), (_) {
      prefs.setInt("lastWork",
          DateTime.now().add(Duration(minutes: 2)).millisecondsSinceEpoch);
    });
  }
}

Future<void> worker() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> usersLiked = List<String>();
  bool init = false;

  try {
    initNotifications();
    Server.instance.signIn().then((signedIn) {
      if (signedIn) {
        Server.instance.likesProfileList().listen((dataLikedUsers) async {
          if (init) {
            dataLikedUsers.documents.forEach((documentLikedUser) async {
              if (!usersLiked.contains(documentLikedUser.documentID)) {
                bool likedBack = Server.instance
                    .checkOwnUserLikedBack(documentLikedUser.documentID, true);
                usersLiked.add(documentLikedUser.documentID);
                prefs.setStringList("usersLiked", usersLiked);
                if (likedBack) chatMessageStream(documentLikedUser);
                showNotification(likedBack ? "Match!" : "New like!",
                    "with " + documentLikedUser.data["name"]);
              }
            });
          } else {
            init = true;
            if (prefs.getStringList("usersLiked") != null)
              usersLiked.addAll(prefs.getStringList("usersLiked"));
            dataLikedUsers.documents.forEach((documentLikedUser) {
              bool likedBack = Server.instance
                  .checkOwnUserLikedBack(documentLikedUser.documentID, true);
              if (!usersLiked.contains(documentLikedUser.documentID)) {
                showNotification(likedBack ? "Match!" : "New like!",
                    "with " + documentLikedUser.data["name"]);
                usersLiked.add(documentLikedUser.documentID);
                prefs.setStringList("usersLiked", usersLiked);
              }
              if (likedBack) {
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
  bool init = false;
  Server.instance.chatStream(documentLikedUser.documentID).listen((dataChat) {
    if (dataChat.documents.length > 0) {
      if (!(dataChat.documents.first.data["messages"]
                  .last[Server.instance.firebaseUser.uid.substring(0, 6)] ??=
              false) &&
          init) {
        showNotification(documentLikedUser.data["name"],
            dataChat.documents.first.data["messages"].last["m"].toString());
      } else
        init = true;
    }
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
    return;
  });

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '0', 'Notifications', 'For chats, matches etc.');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
}
