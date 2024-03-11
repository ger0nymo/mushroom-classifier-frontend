part of 'camera_bloc.dart';

sealed class CameraEvent {
  const CameraEvent();
}

class InitializeCameraEvent extends CameraEvent {
  const InitializeCameraEvent();
}

class CameraRetryEvent extends CameraEvent {
  const CameraRetryEvent();
}

class CameraScanEvent extends CameraEvent {
  final File? imageFile;

  const CameraScanEvent({this.imageFile});
}

class CameraScanLoadingEvent extends CameraEvent {
  const CameraScanLoadingEvent();
}

class CameraSuccessEvent extends CameraEvent {
  final String response;

  const CameraSuccessEvent(this.response);
}

class CaptureImageEvent extends CameraEvent {
  final File? imageFile;

  const CaptureImageEvent({this.imageFile});
}