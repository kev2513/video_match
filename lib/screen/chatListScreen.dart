import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:video_match/screen/chat.dart';
import 'package:video_match/screen/otherUserScreen.dart';
import 'package:video_match/server/server.dart';
import 'package:video_match/utils/ui/div.dart';

class ChatsList extends StatefulWidget {
  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: StreamBuilder(
        stream: Server.instance.likesProfileList(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting)
            return VMLoadingCircle();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "People which liked you:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      if (Server.instance.checkOwnUserLikedBack(
                          snapshot.data.documents[index].documentID, false)) {
                        Map<String, dynamic> data =
                            snapshot.data.documents[index].data;
                        data["uid"] = snapshot.data.documents[index].documentID;
                        return UserImageCircle(data);
                      } else
                        return Container();
                    },
                  ),
                ),
              ),
              Text(
                "Chats:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      if (Server.instance.checkOwnUserLikedBack(
                          snapshot.data.documents[index].documentID, true))
                        return UserChatCard(snapshot.data.documents[index].data,
                            snapshot.data.documents[index].documentID);
                      else
                        return Container();
                    },
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class UserImageCircle extends StatelessWidget {
  UserImageCircle(this.data, {this.mini = false});
  final Map<String, dynamic> data;
  final bool mini;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () {
          if (!mini)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OtherUserScreen(data)),
            );
        },
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
      ),
    );
  }
}

class UserChatCard extends StatefulWidget {
  UserChatCard(this.data, this.uidOtherUser);
  final Map<String, dynamic> data;
  final String uidOtherUser;

  @override
  _UserChatCardState createState() => _UserChatCardState();
}

class _UserChatCardState extends State<UserChatCard> {
  bool deleted = false;

  @override
  Widget build(BuildContext context) {
    return (!deleted)
        ? GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Chat(widget.data, widget.uidOtherUser)),
              );
            },
            onLongPress: () {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: Text(
                          "Are you sure?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text("Do you want to delete the chat with " +
                                widget.data["name"] +
                                "?"),
                            Divider(
                              color: Colors.transparent,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                FlatButton(
                                  color: Colors.red,
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    Server.instance
                                        .rateUser(widget.uidOtherUser, false);
                                    setState(() {
                                      deleted = true;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                                FlatButton(
                                  child: Text(
                                    "Cancle",
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ));
            },
            child: Card(
              child: Row(
                children: <Widget>[
                  UserImageCircle(
                    widget.data,
                    mini: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      widget.data["name"],
                    ),
                  )
                ],
              ),
            ),
          )
        : Container();
  }
}
