import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'mqtt_event.dart';
part 'mqtt_state.dart';

class MqttBloc extends Bloc<MqttEvent, MqttState> {
  MqttBloc() : super(MqttInitial()) {
    on<MqttEvent>((event, emit) {
    });
  }
}
