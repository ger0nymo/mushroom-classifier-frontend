import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:mushroom_classifier/features/camera/models/result.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraController? _cameraController;

  CameraBloc() : super(CameraInitial()) {
    on<InitializeCameraEvent>((event, emit) async {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );
      _cameraController!.setFlashMode(FlashMode.off);
      await _cameraController!.initialize();
      emit(CameraInitialized(_cameraController!, null));
    });

    on<CameraRetryEvent>((event, emit) async {
      await _cameraController!.initialize();
      emit(CameraInitialized(_cameraController!, null));
    });

    on<CameraScanEvent>((event, emit) async {
      emit(CameraLoading());
      final response = await _uploadImage(XFile(event.imageFile!.path));

      Result result = Result.fromJson(json.decode(response));

      emit(CameraInitialized(_cameraController!, result));
    });

    on<CameraScanLoadingEvent>((event, emit) async {
      emit(CameraLoading());
    });

    on<CaptureImageEvent>((event, emit) async {
      _cameraController!.setFlashMode(FlashMode.off);
      final imageFile = await _cameraController!.takePicture();
      emit(CameraCaptured(imageFile.path, _cameraController!));
    });


  }

  Future<String> _uploadImage(XFile imageFile) async {
    try {
      final uri = Uri.parse("http://152.66.237.111:5000/upload");
      final dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path, filename: imageFile.path.split('/').last),
      });
      final response = await dio.postUri(uri, data: formData);
      return response.data ?? "Success";
    } catch (e) {

      return "Error: $e";
    }
  }

  @override
  Future<void> close() {
    _cameraController?.dispose();
    return super.close();
  }
}