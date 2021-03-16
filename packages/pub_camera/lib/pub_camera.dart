library pub_camera;

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

part 'camera/camera_screen.dart';
part 'camera/preview_screen.dart';
part 'camera/preview_video.dart';
part 'camera/chewie_video.dart';