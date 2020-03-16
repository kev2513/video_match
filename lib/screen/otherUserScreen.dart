import 'package:flutter/material.dart';
import 'package:video_match/screen/otherUserVideo.dart';
import 'package:video_match/utils/ui/VMScaffold.dart';

class OtherUserScreen extends StatefulWidget {
  OtherUserScreen(this.data);
  final Map<String, dynamic> data;
  @override
  _OtherUserScreenState createState() => _OtherUserScreenState();
}

class _OtherUserScreenState extends State<OtherUserScreen> {
  @override
  Widget build(BuildContext context) {
    return VMScaffold(body: OtherUserVideo(data: widget.data,));
  }
}
