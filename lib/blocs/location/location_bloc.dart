import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:she_sos/services/location_service.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _service;
  StreamSubscription<Position>? _sub;

  LocationBloc(this._service) : super(LocationInitial()) {
    on<LocationStart>((event, emit) async {
      final ok = await _service.ensurePermissions();
      if (!ok) return emit(LocationError('Location permission denied'));

      emit(LocationLoading());
      _sub?.cancel();

      _sub = _service.positionStream.listen((pos) {
        add(LocationUpdated(pos));
      });
    });

    on<LocationUpdated>((event, emit) {
      emit(LocationReady(event.position));
    });

    on<LocationStop>((event, emit) async {
      await _sub?.cancel();
      emit(LocationInitial());
    });
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
