part of 'location_bloc.dart';

abstract class LocationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LocationStart extends LocationEvent {}

class LocationUpdated extends LocationEvent {
  final Position position;
  LocationUpdated(this.position);

  @override
  List<Object?> get props => [position];
}

class LocationStop extends LocationEvent {}
