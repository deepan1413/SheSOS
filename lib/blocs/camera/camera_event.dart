
part of 'camera_bloc.dart';


abstract class CameraEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CameraInit extends CameraEvent {}

class CameraTakePicture extends CameraEvent {}

class CameraStartVideo extends CameraEvent {}

class CameraStopVideo extends CameraEvent {}
