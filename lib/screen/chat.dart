import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_match/utils/colors.dart';
import 'package:video_match/utils/server/server.dart';
import 'package:video_match/utils/ui/VMScaffold.dart';
import 'package:video_match/utils/ui/div.dart';

class Chat extends StatefulWidget {
  Chat(this.data, this.uidOtherUser);
  Map<String, dynamic> data = Map<String, dynamic>();
  String uidOtherUser;
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController textEditingController = TextEditingController();
  ScrollController scrollController = ScrollController();

  sendMessage() {
    Server.instance
        .sendChatMessage(widget.uidOtherUser, textEditingController.text);
    textEditingController.text = "";
  }

  @override
  void initState() {
    super.initState();
    setState(() {});
    textEditingController.addListener(() {
      if (scrollController.offset != 0.0)
        scrollController.animateTo(
          0.0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    QuerySnapshot data;
    return VMScaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              reverse: true,
              controller: scrollController,
              children: <Widget>[
                StreamBuilder(
                  stream: Server.instance.chatStream(widget.uidOtherUser),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return VMLoadingCircle();

                    data = snapshot.data;
                    List<Widget> messages = List<Widget>();
                    List<dynamic> dataList = List<dynamic>();
                    if (data.documents.isNotEmpty) {
                      dataList = data.documents.first.data["messages"];
                    }

                    dataList.forEach((block) {
                      var map = Map<String, dynamic>.from(block);
                      bool ownMessage = block[
                          Server.instance.firebaseUser.uid.substring(0, 6)];
                      messages.add(MessageCard(
                        message: map["m"].toString(),
                        ownMessage: ownMessage,
                      ));
                    });

                    return Column(
                      children: (messages.isNotEmpty)
                          ? messages
                          : [
                              Text(
                                  "Write something nice and make the first steep 😇")
                            ],
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(),
          Row(
            children: <Widget>[
              Flexible(
                child: TextField(
                  onEditingComplete: () => sendMessage(),
                  controller: textEditingController,
                ),
              ),
              FloatingActionButton(
                mini: true,
                heroTag: null,
                onPressed: () => sendMessage(),
                child: Icon(
                  Icons.send,
                ),
              )
            ],
          )
        ],
      ),
    ));
  }
}

class MessageCard extends StatefulWidget {
  const MessageCard({this.message, this.ownMessage});
  @required
  final String message;
  @required
  final bool ownMessage;
  @override
  _MessageCardState createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    int intOfFirstChar = widget.message.codeUnitAt(0);
    bool singleEmoji = false;
    if (intOfFirstChar >= 55350 &&
        intOfFirstChar <= 55360 &&
        widget.message.length == 2) // range of symbols (tested)
      singleEmoji = true;
    return Padding(
      padding: (widget.ownMessage)
          ? EdgeInsets.only(left: 100)
          : EdgeInsets.only(right: 100),
      child: Align(
        alignment:
            (widget.ownMessage) ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: widget.message));
            final snackBar = SnackBar(
              content: Text(
                "Copied to clipboard",
                textAlign: TextAlign.center,
              ),
              backgroundColor: mainColor,
            );
            Scaffold.of(context).showSnackBar(snackBar);
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.message,
                style: TextStyle(fontSize: (singleEmoji) ? 50.0 : 14.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
