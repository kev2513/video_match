import 'package:flutter/material.dart';
import 'package:video_match/screen/createVideo.dart';
import 'package:video_match/screen/playVideo.dart';
import 'package:video_match/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return VMScaffold(
        child: PageView(
      children: <Widget>[PlayVideo(), CreateVideo()],
    ));
  }
}

class VMScaffold extends StatefulWidget {
  VMScaffold({this.child, this.floatingActionButton, this.colorfulBackground = false});
  final Widget child;
  final Widget floatingActionButton;
  final bool colorfulBackground;
  @override
  _VMScaffoldState createState() => _VMScaffoldState();
}

class _VMScaffoldState extends State<VMScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/app_lable.png",
          height: 40,
        ),
      ),
      body: Stack(children: <Widget>[
        (widget.colorfulBackground)
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(.75, .75),
                    colors: [
                      mainColor.withOpacity(.8),
                      secondaryColor.withOpacity(.8)
                    ],
                    tileMode: TileMode.repeated,
                  ),
                ),
              )
            : Container(),
        widget.child
      ]),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
