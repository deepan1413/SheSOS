part of 'camera_bloc.dart';

abstract class CameraState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CameraInitial extends CameraState {}

class CameraReady extends CameraState {
  final CameraController controller;
  CameraReady(this.controller);

  @override
  List<Object?> get props => [controller];
}

class CameraCaptured extends CameraState {
  final File picture;
  CameraCaptured(this.picture);

  @override
  List<Object?> get props => [picture];
}

class CameraRecording extends CameraState {}

class CameraVideoSaved extends CameraState {
  final File video;
  CameraVideoSaved(this.video);

  @override
  List<Object?> get props => [video];
}

class CameraError extends CameraState {
  final String message;
  CameraError(this.message);

  @override
  List<Object?> get props => [message];
}
