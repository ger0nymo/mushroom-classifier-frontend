part of 'camera_bloc.dart';

sealed class CameraState {
  const CameraState();
}

class CameraInitial extends CameraState {}

class CameraInitialized extends CameraState {
  final CameraController cameraController;
  final Result? result;

  const CameraInitialized(this.cameraController, this.result);
}

class CameraCaptured extends CameraState {
  final String imagePath;
  final CameraController cameraController;

  const CameraCaptured(this.imagePath, this.cameraController);
}

class CameraLoading extends CameraState {}

class CameraSuccess extends CameraState {
  final String response;

  const CameraSuccess(this.response);
}

class CameraError extends CameraState {
  final String error;

  const CameraError(this.error);
}