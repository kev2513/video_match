import 'package:flutter/material.dart';

class VMScaffold extends StatefulWidget {
  VMScaffold(
      {this.body,
      this.bottomNavigationBar,
      this.floatingActionButton,
      this.colorfulBackground = false});
  final Widget body;
  final Widget floatingActionButton;
  final Widget bottomNavigationBar;

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
                color: Colors.white,
              )
            : Container(),
        widget.body
      ]),
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
