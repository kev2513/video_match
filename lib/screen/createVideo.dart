import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_match/utils/colors.dart';
import 'package:video_player/video_player.dart';

Future<String> getSelfVideoPath({bool deleteOnExist = false}) async {
  File videoFilePath =
      File((await getTemporaryDirectory()).path + "/selfVideo.mp4");
  if (await videoFilePath.exists() && deleteOnExist) {
    await videoFilePath.delete();
  }
  return videoFilePath.path;
}

Future<String> getSelfiePath({bool deleteOnExist = false}) async {
  File selfieFilePath =
      File((await getTemporaryDirectory()).path + "/selfie.jpg");
  if (await selfieFilePath.exists() && deleteOnExist) {
    await selfieFilePath.delete();
  }
  return selfieFilePath.path;
}

class CreateVideo extends StatefulWidget {
  CreateVideo({this.onVideoCreated, this.onVideoDeleted});
  final Function onVideoCreated;
  final Function onVideoDeleted;
  @override
  _CreateVideoState createState() => _CreateVideoState();
}

class _CreateVideoState extends State<CreateVideo> {
  CameraController _cameraController;
  bool _cameraGranted = false;
  double _sliderProgress = 0;
  bool _recordState = true;
  Timer _recodringTimer;
  bool _videoPlay = false;
  bool _showRecordButton = true;

  VideoPlayerController _videoPlayerController;

  _initVideoPlayer() async {
    String path = await getSelfVideoPath();
    _videoPlayerController = VideoPlayerController.file(File(path));
    _videoPlayerController.initialize();
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

  _startRecording() async {
    if (_recodringTimer == null && _recordState) {
      _videoPlay = false;
      setState(() {
        _showRecordButton = false;
      });
      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          _showRecordButton = true;
        });
      });
      await _cameraController
          .takePicture(await getSelfiePath(deleteOnExist: true));
      await _cameraController
          .startVideoRecording(await getSelfVideoPath(deleteOnExist: true));
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
      if (!(await _checkFace() > 0)) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text(
                    "Sorry",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                      "No face found please be clearly visible. At the beginning of the video."),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      } else {
        widget.onVideoCreated();
      }
    }
  }

  Future<int> _checkFace() async {
    FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFilePath(await getSelfiePath());
    FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
    List<Face> faces = await faceDetector.processImage(visionImage);
    return faces.length;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (!_cameraGranted)
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Please allow access to your camera and microphone to record your video",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
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
                      alignment: Alignment(.4, .8),
                      child: FloatingActionButton(
                        heroTag: null,
                        backgroundColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            _videoPlay = false;
                            _videoPlayerController.pause();
                            widget.onVideoDeleted();
                          });
                        },
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    )
                  : Container(),
              (_videoPlay)
                  ? Align(
                      alignment: Alignment(-.4, .8),
                      child: FloatingActionButton(
                        heroTag: null,
                        backgroundColor: Colors.white,
                        onPressed: () {
                          _videoPlayerController.seekTo(Duration(seconds: 0));
                        },
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.blue,
                        ),
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
              (!_videoPlay && _showRecordButton)
                  ? Align(
                      alignment: Alignment(0, .9),
                      child: FloatingActionButton(
                        heroTag: null,
                        child: Icon(
                            (_recordState)
                                ? Icons.fiber_manual_record
                                : Icons.stop,
                            color: (_recordState) ? Colors.red : mainColor),
                        onPressed: () {
                          if (_recordState)
                            _startRecording();
                          else {
                            _recodringTimer.cancel();
                            _stopRecording();
                          }
                        },
                        backgroundColor: Colors.white,
                      ),
                    )
                  : Container(),
            ],
          );
  }
}
