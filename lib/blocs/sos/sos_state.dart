part of 'sos_bloc.dart';


abstract class SosState extends Equatable {
@override
List<Object?> get props => [];
}


class SosIdle extends SosState {}
class SosSending extends SosState {}
class SosSent extends SosState {
final String sosId;
SosSent(this.sosId);
@override
List<Object?> get props => [sosId];
}
class SosError extends SosState {
final String message;
SosError(this.message);
@override
List<Object?> get props => [message];
}