part of 'location_bloc.dart';

abstract class LocationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationReady extends LocationState {
  final Position position;
  LocationReady(this.position);

  @override
  List<Object?> get props => [position];
}

class LocationError extends LocationState {
  final String message;
  LocationError(this.message);

  @override
  List<Object?> get props => [message];
}
