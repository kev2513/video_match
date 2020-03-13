import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_match/server/server.dart';
import 'package:video_match/utils/colors.dart';
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
    return VMScaffold(
      body: Column(
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

                    QuerySnapshot data = snapshot.data;
                    List<Widget> messages = List<Widget>();
                    List<dynamic> dataList = List<dynamic>();
                    if (data.documents.isEmpty) {
                      return Message_Card(
                          message:
                              "Write something nice and make the first steep 😇");
                    } else {
                      dataList = data.documents.first.data["messages"];
                    }

                    dataList.forEach((block) {
                      var map = Map<String, dynamic>.from(block);
                      double paddingSize = 100.0;
                      EdgeInsetsGeometry padding = (true)
                          ? EdgeInsets.only(left: paddingSize)
                          : EdgeInsets.only(right: paddingSize);
                      messages.add(Padding(
                        padding: padding,
                        child: Align(
                          child: Message_Card(message: map["m"].toString()),
                          alignment: (true)
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                        ),
                      ));
                    });

                    return Column(
                      children: messages,
                    );
                  },
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: TextField(
                  onEditingComplete: () {
                    sendMessage();
                  },
                  controller: textEditingController,
                  maxLength: 400,
                ),
              ),
              FlatButton(
                onPressed: () {
                  sendMessage();
                },
                child: Icon(
                  Icons.send,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class Message_Card extends StatefulWidget {
  const Message_Card({this.message});
  final String message;
  @override
  _Message_CardState createState() => _Message_CardState();
}

class _Message_CardState extends State<Message_Card> {
  @override
  Widget build(BuildContext context) {
    int intOfFirstChar = widget.message.codeUnitAt(0);
    bool singleEmoji = false;
    if (intOfFirstChar >= 55350 &&
        intOfFirstChar <= 55360 &&
        widget.message.length == 2) // range of symbols (tested)
      singleEmoji = true;
    return GestureDetector(
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
        child: Text(
          widget.message,
          style: TextStyle(fontSize: (singleEmoji) ? 50.0 : 14.0),
        ),
      ),
    );
  }
}
