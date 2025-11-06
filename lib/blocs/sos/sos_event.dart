part of 'sos_bloc.dart';


abstract class SosEvent extends Equatable {
@override
List<Object?> get props => [];
}


class SosTrigger extends SosEvent {
final String? message;
final File? mediaFile; // audio or short video snapshot
SosTrigger({this.message, this.mediaFile});
}


class SosCancel extends SosEvent {}