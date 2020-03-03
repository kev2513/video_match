import 'package:flutter/material.dart';

class RoundedButton extends StatefulWidget {
  RoundedButton({this.text, this.onPressed, this.color});
  final String text;
  final Function onPressed;
  final Color color;
  @override
  _RoundedButtonState createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<RoundedButton> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
          side: BorderSide(color: widget.color)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          widget.text,
          style: TextStyle(fontSize: 30, color: widget.color),
        ),
      ),
      onPressed: () {
        widget.onPressed();
      },
    );
  }
}
