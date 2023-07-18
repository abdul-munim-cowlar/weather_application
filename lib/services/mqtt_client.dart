import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../utilities/config.dart';

final StreamController<String> streamController =
    StreamController<String>.broadcast();

class MQTTClientConnection {
  late MqttServerClient client;

  _onConnected() {
    client.updates!.listen((event) async {
      final topic = event[0].topic;
      final MqttMessage message = event[0].payload;
      try {} catch (e) {
        log(e.toString());
      }
      if (message is MqttPublishMessage) {
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);
        log("$topic-> $payload");
        streamController.add(payload);
      }
    });
  }

  bool mqttConnectedFirstTime = false;
  bool mqttConnected = false;

  Future<bool> connectClient(String uniqueId) async {
    client = MqttServerClient(
      config.mqttHost,
      uniqueId,
      maxConnectionAttempts: 100,
    );
    // print(config.toString());
    //309694e0-2171-11ee-952d-abd1a64f9721
    client.logging(on: false);
    client.keepAlivePeriod = 3;
    client.port = config.mqttPort;
    // client.secure = false;
    client.onConnected = _onConnected;
    client.onAutoReconnected = _onAutoReconnected;
    client.onAutoReconnect = _onAutoReconnect;
    client.resubscribeOnAutoReconnect = true;
    client.autoReconnect = true;
    client.onDisconnected = onDisconnected;
    client.securityContext = SecurityContext.defaultContext;
    // client.useWebSocket = true;
    // client.setProtocolV311();
    client.secure = config.mqttSSL;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(uniqueId)
        // .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    connMess.authenticateAs(config.mqttUsername, config.mqttPassword);
    client.connectionMessage = connMess;
    mqttConnectedFirstTime = true;

    final response =
        await client.connect(config.mqttUsername, config.mqttPassword);
    log(response.toString());
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      return true;
    } else {
      mqttConnected = false;
      return false;
    }
  }

  _onAutoReconnected() {
    log(client.connectionStatus.toString());
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      _onConnected();
    } else {
      // storage.isMqttConnected = false;
    }
  }

  _onAutoReconnect() {
    log("--- mqtt_client.dart: reconnecting to mqtt... ");
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>>? subscribe(String subTopic,
      {qos = MqttQos.atLeastOnce}) {
    log("mqtt_client.dart | topic: $subTopic | qos: $qos");
    client.subscribe(
      subTopic,
      qos,
    );
    log("subscribed to topic: $subTopic");
    return client.updates!;
  }

  void unsubscribe(String topic) {
    client.unsubscribe(topic, expectAcknowledge: true);
  }

  void publish(String pubTopic, String message, {bool retain = false}) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message.toString());

    client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload!,
        retain: retain);
  }

  void onDisconnected() {
    mqttConnected = false;

    log("Disconnected");
  }

  void pong() {
    log("Ping response client callback invoked");
  }
}
