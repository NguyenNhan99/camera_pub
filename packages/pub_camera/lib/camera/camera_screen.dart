part of pub_camera;
// import 'dart:async';
//
//
// import 'package:camera/camera.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_navigation/src/root/get_material_app.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:stop_watch_timer/stop_watch_timer.dart';
// import 'package:video_player/video_player.dart';
// import 'preview_screen.dart';
// import 'preview_video.dart';


class CameraScreen extends StatefulWidget {
  final int timeOutVideoCamera;
  final bool compressVideo;
  final bool compressImage;
  ValueChanged<File> onResutl;

  CameraScreen({this.timeOutVideoCamera = 0, this.compressVideo = false,this.compressImage = false, this.onResutl});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List cameras;
  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  final BehaviorSubject<bool> visibilityController =
  BehaviorSubject<bool>.seeded(false);
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    isLapHours: true,
  );
  CameraController controller;
  FlashMode flashMode = FlashMode.off;
  int selectedCameraIndex = 0;
  XFile imageFile;
  XFile videoFile;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  bool enableAudio = true;
  bool check = true;
  // int timeOut;
  Timer _timer;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  double scale = 1.0;

  List<String> text = <String>[
    'CHỤP ẢNH',
    'VIDEO',
  ];

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    controller?.dispose();
    visibilityController.close();
    videoController.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIndex = 0;
        });
        _initCameraController(cameras[selectedCameraIndex]).then((void v) {});
      } else {
        print('No camera available');
      }
    }).catchError((err) {
      print('Error :${err.code}Error message : ${err.message}');
    });
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
      await Future.wait([
        controller.getMaxZoomLevel().then((value) => _maxAvailableZoom = value),
        controller.getMinZoomLevel().then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      print(e);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: _cameraPreviewWidget(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraPreviewWidget(context) {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    return StreamBuilder(
        stream: visibilityController.stream,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return Stack(
            children: [
              Positioned.fill(
                child: Listener(
                  onPointerDown: (_) => _pointers++,
                  onPointerUp: (_) => _pointers--,
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CameraPreview(
                      controller,
                      child: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onScaleStart: _handleScaleStart,
                          onScaleUpdate: _handleScaleUpdate,
                          onTapDown: (details) =>
                              onViewFinderTap(details, constraints),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              (snapshot.data == false)
                  ? Positioned(
                  top: 15,
                  left: 15,
                  child: GestureDetector(
                      onTap: () {
                        //Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios_outlined,
                        color: Colors.white,
                        size: 30,
                      )))
                  : SizedBox.shrink(),
              (snapshot.data == false && (text[0] == 'CHỤP ẢNH'))
                  ? Positioned(top: 10, right: 80, child: _flashButton())
                  : SizedBox.shrink(),
              (snapshot.data == false)
                  ? Positioned(
                top: 15,
                right: 20,
                child: _cameraTogglesRowWidget(),
              )
                  : SizedBox.shrink(),
              (snapshot.data == false)
                  ? Positioned(
                bottom: 10.0,
                left: 0.0,
                right: 0.0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 45),
                  child: (text[0] == 'CHỤP ẢNH')
                      ? GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      //_onCapturePressed(context);
                      onTakePictureButtonPressed(context);
                    },
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: new Container(
                        width: 70.0,
                        height: 70.0,
                        decoration: new BoxDecoration(
                          borderRadius: new BorderRadius.all(
                              new Radius.circular(50.0)),
                          border: new Border.all(
                            color: Colors.white,
                            width: 3.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            width: 30.0,
                            height: 30.0,
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              borderRadius: new BorderRadius.all(
                                  new Radius.circular(50.0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                      : GestureDetector(
                    onTap: () {
                      onVideoRecordButtonPressed();
                      _stopWatchTimer.onExecute
                          .add(StopWatchExecute.start);
                      visibilityController.sink.add(true);
                      if (widget.timeOutVideoCamera != 0) {
                        checkTime(context);
                      }
                    },
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: new Container(
                        width: 70.0,
                        height: 70.0,
                        decoration: new BoxDecoration(
                          borderRadius: new BorderRadius.all(
                              new Radius.circular(50.0)),
                          border: new Border.all(
                            color: Colors.white,
                            width: 3.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            width: 30.0,
                            height: 30.0,
                            decoration: new BoxDecoration(
                              color: Colors.red,
                              borderRadius: new BorderRadius.all(
                                  new Radius.circular(50.0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
                  : SizedBox.shrink(),
              (snapshot.data == false)
                  ? Positioned(
                bottom: 20.0,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    text[0],
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
                  : SizedBox.shrink(),
              (snapshot.data == false)
                  ? Positioned(
                bottom: 20.0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    if (text[0] == 'CHỤP ẢNH') {
                      text.sort((a, b) => a.length.compareTo(b.length));
                    } else {
                      text.sort((a, b) => b.length.compareTo(a.length));
                    }
                    setState(() {});
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 80),
                      child: Text(
                        text[1],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              )
                  : SizedBox.shrink(),
              Positioned(
                right: 15,
                top: 15,
                left: 15,
                child: (text[0] != 'CHỤP ẢNH')
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<int>(
                      stream: _stopWatchTimer.rawTime,
                      initialData:
                      _stopWatchTimer.rawTime.valueWrapper?.value,
                      builder: (context, snap) {
                        final value = snap.data;
                        final displayTime = StopWatchTimer.getDisplayTime(
                            value,
                            milliSecond: false);
                        return Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                displayTime,
                                style: const TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    (widget.timeOutVideoCamera != 0)
                        ? Text('/ ', style: TextStyle(color: Colors.red))
                        : SizedBox.shrink(),
                    (widget.timeOutVideoCamera != 0)
                        ? Text(
                      ' 00:00:${widget.timeOutVideoCamera.toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.red),
                    )
                        : SizedBox.shrink()
                  ],
                )
                    : SizedBox.shrink(),
              ),
              (snapshot.data != false)
                  ? Positioned(
                bottom: 10.0,
                left: 0.0,
                right: 0.0,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 45),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        onStopButtonPressed();
                        _stopWatchTimer.onExecute
                            .add(StopWatchExecute.reset);
                        visibilityController.sink.add(false);
                      },
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: new Container(
                          width: 70.0,
                          height: 70.0,
                          decoration: new BoxDecoration(
                            borderRadius: new BorderRadius.all(
                                new Radius.circular(50.0)),
                            border: new Border.all(
                              color: Colors.white,
                              width: 3.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Container(
                              width: 10.0,
                              height: 10.0,
                              decoration: new BoxDecoration(
                                color: Colors.red,
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(2.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
              )
                  : SizedBox.shrink(),
            ],
          );
        });
  }

  Widget _cameraTogglesRowWidget() {
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;
    return GestureDetector(
      onTap: () {
        _onSwitchCamera();
      },
      child: Icon(
        getCameraLensIcon(lensDirection),
        color: Colors.white,
        size: 30,
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller.setZoomLevel(_currentScale);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<XFile> takePicture() async {
    final CameraController cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      //showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print(e);
      return null;
    }
  }

  void onTakePictureButtonPressed(context) {
    takePicture().then((XFile file) {
      if (mounted) {
        if (file != null) {
          print('Picture saved to ${file.path}');
          // widget.fileImage(File(file.path));
          Get.to(PreviewScreen(fileImage: widget.onResutl,
            imgPath: file.path,compress: widget.compressImage,
          ));
        }
      }
    });
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        // showInSnackBar(
        //     'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onSwitchCamera() async {
    selectedCameraIndex =
    selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];

    _initCameraController(selectedCamera);
  }

  IconData getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return CupertinoIcons.switch_camera;
      case CameraLensDirection.front:
        return CupertinoIcons.switch_camera_solid;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        throw ArgumentError('Unknown lens direction');
    }
  }

  Widget _flashButton() {
    IconData iconData = Icons.flash_off;
    Color color = Colors.white;
    if (flashMode == FlashMode.always) {
      iconData = Icons.flash_on;
      color = Colors.white;
    }
    return IconButton(
      icon: Icon(iconData),
      color: color,
      onPressed: controller != null && controller.value.isInitialized
          ? _onFlashButtonPressed
          : null,
    );
  }

  Future<void> _onFlashButtonPressed() async {
    if (flashMode == FlashMode.off || flashMode == FlashMode.torch) {
      // Turn on the flash for capture
      flashMode = FlashMode.always;
    } else if (flashMode == FlashMode.always) {
      // Turn on the flash for capture if needed
      flashMode = FlashMode.auto;
    } else {
      // Turn off the flash
      flashMode = FlashMode.off;
    }
    // Apply the new mode
    await controller.setFlashMode(flashMode);

    // Change UI State
    setState(() {});
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> startVideoRecording() async {
    final CameraController cameraController = controller;

    // final Directory extDir = await getApplicationDocumentsDirectory();
    // final String dirPath = '${extDir.path}/Movies/flutter_test';
    // await Directory(dirPath).create(recursive: true);
    // final String filePath = '$dirPath/${timestamp()}.mp4';

    if (cameraController == null || !cameraController.value.isInitialized) {
      //showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return;
    }
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((file) {
      if (mounted) setState(() {});
      if (file != null) {
        videoFile = file;
        //print(file.path);

        //Get.to(() => ChewieVideo(videoPlayerController: VideoPlayerController.file(File(videoFile.path)),autoPlay: true,looping: true,));
        Get.to(() => PreviewVideo(fileVideo: widget.onResutl,
          videoPath: file.path,compress: widget.compressVideo,
        ));
      }
    });
    if (_timer != null) _timer.cancel();
  }

  Future<XFile> stopVideoRecording() async {
    final CameraController cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return null;
    }
  }

  void checkTime(context) {
    _timer = Timer.periodic(Duration(seconds: widget.timeOutVideoCamera + 1), (Timer t) {
      _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
      visibilityController.sink.add(false);
      onStopButtonPressed();
      _timer.cancel();
    });  }
}
