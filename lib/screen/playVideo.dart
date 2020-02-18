import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_match/utils/colors.dart';
import 'package:video_player/video_player.dart';

class PlayVideo extends StatefulWidget {
  @override
  _PlayVideoState createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  VideoPlayerController _videoPlayerController;
  bool playing = false;
  @override
  void initState() {
    super.initState();
    FirebaseStorage()
        .ref()
        .child("path.mp4")
        .getDownloadURL()
        .catchError((_) {})
        .then((videoUrl) async {
      if (videoUrl != null) {
        _videoPlayerController = VideoPlayerController.network(videoUrl);
        await _videoPlayerController.initialize();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      (_videoPlayerController != null)
          ? Transform.scale(
              scale: _videoPlayerController.value.aspectRatio /
                  (MediaQuery.of(context).size.width /
                      MediaQuery.of(context).size.height),
              child: Center(
                child: AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController),
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      (!playing && _videoPlayerController != null)
          ? Align(
              alignment: Alignment.center,
              child: IconButton(
                onPressed: () {
                  if (_videoPlayerController != null) {
                    _videoPlayerController.play();
                    setState(() {
                      playing = true;
                    });
                  }
                },
                icon: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                ),
                iconSize: 100,
              ),
            )
          : Container(),
      Align(
        alignment: Alignment(.95, -.95),
        child: FloatingActionButton(
          mini: true,
          backgroundColor: Colors.red,
          onPressed: () {},
          child: Icon(Icons.report),
        ),
      ),
      Align(
        alignment: Alignment(-.5, .8),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: secondaryColor,
          child: Icon(
            Icons.navigate_next,
            size: 40,
          ),
        ),
      ),
      Align(
        alignment: Alignment(0, .9),
        child: FloatingActionButton(
          mini: true,
          backgroundColor: Colors.lightGreen,
          onPressed: () {
            _videoPlayerController.seekTo(Duration(seconds: 0));
          },
          child: Icon(Icons.refresh),
        ),
      ),
      Align(
        alignment: Alignment(.5, .8),
        child: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.thumb_up),
          backgroundColor: mainColor,
        ),
      )
    ]);
  }
}
