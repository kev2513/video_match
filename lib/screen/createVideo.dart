import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_match/utils/colors.dart';
import 'package:video_player/video_player.dart';

class CreateVideoScreen extends StatefulWidget {
  @override
  _CreateVideoScreenState createState() => _CreateVideoScreenState();
}

class _CreateVideoScreenState extends State<CreateVideoScreen> {
  CameraController _cameraController;
  bool _cameraGranted = false;
  double _sliderProgress = 0;
  bool _recordState = true;
  Timer _recodringTimer;
  bool _videoPlay = false;

  VideoPlayerController _videoPlayerController;
  Future<void> _initializeVideoPlayerFuture;

  _initVideoPlayer() async {
    String path = await _getSelfVideoPath();
    _videoPlayerController = VideoPlayerController.file(File(path));
    _initializeVideoPlayerFuture = _videoPlayerController.initialize();
    _videoPlayerController.setLooping(true);
    _videoPlayerController.play();
  }

  _accessCamera() {
    availableCameras().then((cameras) {
      _cameraController = CameraController(cameras[1], ResolutionPreset.medium);
      if (_cameraController != null) {
        _cameraController.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            _cameraGranted = true;
          });
        });
      }
    });
  }

  Future<String> _getSelfVideoPath({bool deleteOnExist = false}) async {
    File videoFilePath =
        File((await getTemporaryDirectory()).path + "/selfVideo.mp4");
    if (await videoFilePath.exists() && deleteOnExist) {
      await videoFilePath.delete();
    }
    return videoFilePath.path;
  }

  _startRecording() async {
    if (_recodringTimer == null && _recordState) {
      _videoPlay = false;
      await _cameraController
          .startVideoRecording(await _getSelfVideoPath(deleteOnExist: true));
      _recodringTimer = Timer.periodic(Duration(milliseconds: 60), (timer) {
        if (_sliderProgress < .996)
          setState(() {
            _sliderProgress += .004;
            _recordState = false;
          });
        else {
          timer.cancel();
          _stopRecording();
        }
      });
    }
  }

  _stopRecording() async {
    if (!_recordState) {
      _cameraController.stopVideoRecording();
      await _initVideoPlayer();
      setState(() {
        _recodringTimer = null;
        _sliderProgress = 0;
        _recordState = true;
        _videoPlay = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/app_lable.png",
          height: 40,
        ),
      ),
      body: (!_cameraGranted)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Please allow access to your camera and microphone",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  FlatButton(
                    child: Text(
                      "Allow",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.black,
                    onPressed: () {
                      _accessCamera();
                    },
                  )
                ],
              ),
            )
          : Stack(
              children: <Widget>[
                Transform.scale(
                  scale: _cameraController.value.aspectRatio /
                      (MediaQuery.of(context).size.width /
                          MediaQuery.of(context).size.height),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _cameraController.value.aspectRatio,
                      child: (!_videoPlay)
                          ? CameraPreview(_cameraController)
                          : VideoPlayer(_videoPlayerController),
                    ),
                  ),
                ),
                (_videoPlay)
                    ? Align(
                        alignment: Alignment(-.5, .8),
                        child: FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              _videoPlay = false;
                              _videoPlayerController.pause();
                            });
                          },
                          child: Icon(Icons.replay),
                        ),
                      )
                    : Container(),
                (_videoPlay)
                    ? Align(
                        alignment: Alignment(.5, .8),
                        child: FloatingActionButton(
                          onPressed: () async {
                            final StorageUploadTask uploadTask =
                                FirebaseStorage()
                                    .ref()
                                    .child("path.mp4")
                                    .putFile(File(await _getSelfVideoPath()));

                            await uploadTask.onComplete;
                            print("uploade done!");
                          },
                          child: Icon(Icons.file_upload),
                          backgroundColor: Colors.green,
                        ),
                      )
                    : Container(),
                (!_videoPlay)
                    ? Align(
                        alignment: Alignment(.75, .6),
                        child: Text(
                          "Time remaining: " +
                              (15 - (_sliderProgress * 15)).toInt().toString() +
                              " seconds",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Container(),
                (!_videoPlay)
                    ? Align(
                        alignment: Alignment(0, .7),
                        child: SizedBox(
                            height: 20,
                            child: Slider(
                              value: _sliderProgress,
                              onChanged: (_) {},
                            )),
                      )
                    : Container(),
                (!_videoPlay)
                    ? Align(
                        alignment: Alignment(0, .9),
                        child: FloatingActionButton(
                          child: Icon((_recordState)
                              ? Icons.fiber_manual_record
                              : Icons.stop),
                          onPressed: () {
                            if (_recordState)
                              _startRecording();
                            else {
                              _recodringTimer.cancel();
                              _stopRecording();
                            }
                          },
                          backgroundColor:
                              (_recordState) ? Colors.red : mainColor,
                        ),
                      )
                    : Container(),
              ],
            ),
    );
  }
}
