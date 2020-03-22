import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:video_match/utils/server/server.dart';
import 'package:video_match/utils/colors.dart';
import 'package:video_match/utils/ui/div.dart';
import 'package:video_player/video_player.dart';

class OtherUserVideo extends StatefulWidget {
  OtherUserVideo({this.data});
  final Map<String, dynamic> data;
  @override
  _OtherUserVideoState createState() => _OtherUserVideoState();
}

class _OtherUserVideoState extends State<OtherUserVideo> {
  VideoPlayerController _videoPlayerController;
  bool _playing = false;
  Map<String, dynamic> userData;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_videoPlayerController != null) _videoPlayerController.dispose();
  }

  _pauseVideo() async {
    if (_videoPlayerController != null && _playing) {
      setState(() {
        _playing = false;
      });
      await _videoPlayerController.pause();
      await _videoPlayerController.seekTo(Duration(seconds: 0));
    }
  }

  _nextUser() {
    if (widget.data == null) {
      _pauseVideo();
      _videoPlayerController = null;
      setState(() {});
    } else
      Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        child: FutureBuilder<Map<String, dynamic>>(
          initialData: (widget.data != null) ? widget.data : null,
          future: (widget.data == null) ? Server.instance.recomendUser() : null,
          builder: (BuildContext context,
              AsyncSnapshot<Map<String, dynamic>> snapshot) {
            return (snapshot.hasData)
                ? GestureDetector(
                    onTap: () => _pauseVideo(),
                    child: Stack(children: <Widget>[
                      (!_playing)
                          ? Image.memory(
                              Base64Codec().decode(snapshot.data["image"]),
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                              alignment: Alignment.center,
                            )
                          : Transform.scale(
                              scale: _videoPlayerController.value.aspectRatio /
                                  (MediaQuery.of(context).size.width /
                                      MediaQuery.of(context).size.height),
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio:
                                      _videoPlayerController.value.aspectRatio,
                                  child: VideoPlayer(_videoPlayerController),
                                ),
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment(-.75, -.95),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  (snapshot.data["name"] +
                                      ", " +
                                      snapshot.data["age"]),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 40),
                                ),
                                Text(
                                  (snapshot.data["city"]),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                )
                              ],
                            )),
                      ),
                      Align(
                        alignment: Alignment(.99, -.99),
                        child: FloatingActionButton(
                          heroTag: null,
                          mini: true,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                      title: Text(
                                        "Are you sure you want to report " +
                                            snapshot.data["name"] +
                                            "?",
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              FlatButton(
                                                onPressed: () async {
                                                  Server.instance.rateUser(
                                                      snapshot.data["uid"],
                                                      false,
                                                      otherUserProfileCreationDate:
                                                          (widget.data == null)
                                                              ? snapshot.data[
                                                                  "creationDate"]
                                                              : null);
                                                  _nextUser();
                                                  Server.instance.reportUser(
                                                      snapshot.data["uid"]);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  "Report",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                color: Colors.red,
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  "Cancle",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                color: mainColor,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ));
                          },
                          child: Icon(
                            Icons.report,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      (!_playing && !_loading)
                          ? Align(
                              alignment: Alignment.center,
                              child: IconButton(
                                onPressed: () async {
                                  setState(() {
                                    _loading = true;
                                  });
                                  if (_videoPlayerController == null) {
                                    String videoUrl = await Server.instance
                                        .getVideoUrl(snapshot.data["uid"]);
                                    _videoPlayerController =
                                        VideoPlayerController.network(videoUrl);

                                    await _videoPlayerController.initialize();
                                    await _videoPlayerController
                                        .setLooping(true);
                                  }
                                  _videoPlayerController.play();
                                  setState(() {
                                    _playing = !_playing;
                                    _loading = false;
                                  });
                                },
                                icon: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                iconSize: 60,
                              ),
                            )
                          : Container(),
                      (_loading)
                          ? Center(child: VMLoadingCircle())
                          : Container(),
                      Align(
                        alignment: Alignment(-.5, .9),
                        child: FloatingActionButton(
                          heroTag: null,
                          onPressed: () {
                            Server.instance.rateUser(
                                snapshot.data["uid"], false,
                                otherUserProfileCreationDate:
                                    (widget.data == null)
                                        ? snapshot.data["creationDate"]
                                        : null);
                            _nextUser();
                          },
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.navigate_next,
                            size: 50,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment(.5, .9),
                        child: FloatingActionButton(
                          heroTag: null,
                          onPressed: () async {
                            Server.instance.rateUser(snapshot.data["uid"], true,
                                otherUserProfileCreationDate:
                                    (widget.data == null)
                                        ? snapshot.data["creationDate"]
                                        : null);
                            _nextUser();
                          },
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.thumb_up,
                            size: 30,
                            color: mainColor,
                          ),
                        ),
                      )
                    ]),
                  )
                : Container(
                    color: Colors.grey[100],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "assets/owl.png",
                          height: 150,
                          width: 150,
                        ),
                        Divider(color: Colors.transparent),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "Sorry but currently we cant recommend you any user fitting your requirements.\n\n" +
                                "We are a growing app trying to help you to find genuine people. " +
                                "Please checkout our app from time to time and you will soon find someone.\n\n" +
                                "Thank you for your patience :)",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }
}
