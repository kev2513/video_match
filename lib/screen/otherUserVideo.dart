import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:video_match/server/server.dart';
import 'package:video_match/utils/colors.dart';
import 'package:video_match/utils/ui/div.dart';
import 'package:video_player/video_player.dart';

class OtherUserVideo extends StatefulWidget {
  @override
  _OtherUserVideoState createState() => _OtherUserVideoState();
}

class _OtherUserVideoState extends State<OtherUserVideo> {
  VideoPlayerController _videoPlayerController;
  bool _playing = false;
  Map<String, dynamic> userData;
  bool _loading = false;
  bool reported = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_videoPlayerController != null) _videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Server.instance.recomendUser(),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        return (snapshot.hasData)
            ? GestureDetector(
                onTap: () async {
                  if (_videoPlayerController != null && _playing) {
                    setState(() {
                      _playing = false;
                    });
                    await _videoPlayerController.pause();
                    await _videoPlayerController.seekTo(Duration(seconds: 0));
                  }
                },
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 40),
                            ),
                            Text(
                              (snapshot.data["state"] +
                                  ", " +
                                  snapshot.data["country"]),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            )
                          ],
                        )),
                  ),
                  (!reported)
                      ? Align(
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
                                                    // TODO: add dislike automaticaly
                                                    setState(() {
                                                      reported = true;
                                                    });
                                                    Server.instance
                                                        .reportUser(snapshot.data["uid"]);
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
                        )
                      : Container(),
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
                                await _videoPlayerController.setLooping(true);
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
                  (_loading) ? Center(child: VMLoadingCircle()) : Container(),
                  Align(
                    alignment: Alignment(-.5, .9),
                    child: FloatingActionButton(
                      heroTag: null,
                      onPressed: () {},
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
                      onPressed: () {},
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
            : VMLoadingCircle();
      },
    );
  }
}
