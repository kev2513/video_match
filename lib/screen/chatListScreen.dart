import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_match/server/server.dart';
import 'package:video_match/utils/ui/div.dart';

class ChatsList extends StatefulWidget {
  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Server.instance.likesProfileList(),
      builder: (BuildContext context, snapshot) {
        QuerySnapshot querySnapshot = snapshot.data;
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting)
          return VMLoadingCircle();
        if (snapshot.connectionState == ConnectionState.active) {
          return Column(
            children: <Widget>[
              Text("People which liked you:"),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: querySnapshot.documents.length,
                  itemBuilder: (context, index) {
                    if (Server.instance.checkUserLikedBack(
                        querySnapshot.documents[index].documentID, false))
                      return UserImageCircle(
                          querySnapshot.documents[index].data);
                    else
                      return Container();
                  },
                ),
              ),
              Text("Chats:"),
              Flexible(
                child: ListView.builder(
                  itemCount: querySnapshot.documents.length,
                  itemBuilder: (context, index) {
                    if (Server.instance.checkUserLikedBack(
                        querySnapshot.documents[index].documentID, true))
                      return UserChatCard(querySnapshot.documents[index].data);
                    else
                      return Container();
                  },
                ),
              )
            ],
          );
        }
        return Container();
      },
    );
  }
}

class UserImageCircle extends StatelessWidget {
  UserImageCircle(this.data, {this.mini = false});
  Map<String, dynamic> data = Map<String, dynamic>();
  bool mini;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(90)),
        child: Image.memory(
          Base64Codec().decode(data["image"]),
          fit: BoxFit.cover,
          height: (!mini) ? 100 : 50,
          width: (!mini) ? 100 : 50,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

class UserChatCard extends StatelessWidget {
  UserChatCard(this.data);
  Map<String, dynamic> data = Map<String, dynamic>();
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: <Widget>[
          UserImageCircle(
            data,
            mini: true,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(data["name"],),
          )
        ],
      ),
    );
  }
}
