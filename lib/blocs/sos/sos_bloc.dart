import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:she_sos/services/firebase_service.dart';
import 'package:she_sos/services/notification_service.dart';
import 'package:uuid/uuid.dart';

part 'sos_event.dart';
part 'sos_state.dart';

class SosBloc extends Bloc<SosEvent, SosState> {
  final FirebaseService firebaseService;
  final NotificationService notificationService;
  SosBloc({required this.firebaseService, required this.notificationService})
    : super(SosIdle()) {
    on<SosTrigger>((event, emit) async {
      emit(SosSending());
      try {
        final id = const Uuid().v4();
        await firebaseService.createSos(
          sosId: id,
          message: event.message ?? 'Emergency! Please help',
          mediaFile: event.mediaFile,
        );
        await notificationService.sendTopic("volunteers", {
          'type': 'sos',
          'sosId': id,
        });
        emit(SosSent(id));
      } catch (e) {
        emit(SosError(e.toString()));
      }
    });

    on<SosCancel>((event, emit) async {
      emit(SosIdle());
    });
  }
}
