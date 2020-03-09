import 'package:flutter/material.dart';
import 'package:video_match/utils/colors.dart';

class VMButton extends StatefulWidget {
  VMButton(
      {this.text, this.onPressed, this.color = secondaryColor, this.size = 25});
  final String text;
  final Function onPressed;
  final Color color;
  final double size;
  @override
  _VMButtonState createState() => _VMButtonState();
}

class _VMButtonState extends State<VMButton> {
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
          style: TextStyle(fontSize: widget.size, color: widget.color),
        ),
      ),
      onPressed: () {
        widget.onPressed();
      },
    );
  }
}

class VMLoadingCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
            height: 25,
            width: 25,
            child: CircularProgressIndicator(
              backgroundColor: mainColor,
            )),
      ],
    );
  }
}

Widget loadingDialog(BuildContext context) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text(
                "Uploading...",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: VMLoadingCircle(),
            ),
          ));
}
