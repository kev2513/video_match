import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_match/utils/colors.dart';

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

  _accessCamera() {
    availableCameras().then((cameras) {
      _cameraController = CameraController(cameras[1], ResolutionPreset.medium);
      if (_cameraController != null)
        _cameraController.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            _cameraGranted = true;
          });
        });
    });
  }

  _startRecording() {
    if (_recodringTimer == null && _recordState) {
      //_cameraController.startVideoRecording("selfVideo.mp4");
      _recodringTimer = Timer.periodic(Duration(milliseconds: 60), (timer) {
        if (_sliderProgress < .999)
          setState(() {
            _sliderProgress += .001;
            _recordState = false;
          });
        else
          _stopRecording();
      });
    }
  }

  _stopRecording() {
    if (!_recordState) {
      //_cameraController.stopVideoRecording();
      setState(() {
        _recodringTimer.cancel();
        _recodringTimer = null;
        _sliderProgress = 0;
        _recordState = true;
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
                      child: CameraPreview(_cameraController),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(.75, .6),
                  child: Text(
                    "Time remaining: " +
                        (60 - (_sliderProgress * 60)).toInt().toString() +
                        " seconds",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Align(
                  alignment: Alignment(0, .7),
                  child: SizedBox(
                      height: 20,
                      child: Slider(
                        value: _sliderProgress,
                        onChanged: (_) {},
                      )),
                ),
                Align(
                  alignment: Alignment(0, .9),
                  child: FloatingActionButton(
                    child: Icon((_recordState)
                        ? Icons.fiber_manual_record
                        : Icons.stop),
                    onPressed: () {
                      if (_recordState)
                        _startRecording();
                      else
                        _stopRecording();
                    },
                    backgroundColor: (_recordState) ? Colors.red : mainColor,
                  ),
                ),
              ],
            ),
    );
  }
}
