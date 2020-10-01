/**
 * Source code: https://www.emqx.io/blog/using-mqtt-in-flutter
 * After connecting to client:
 * client.subscribe("atopic", MqttQos.atMostOnce)
 */

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// Connect to MQTT broker (HIVEMQ).
/// Configurations can be given as parameters if needed.
Future<MqttServerClient> connect() async {

  MqttServerClient client =
    MqttServerClient.withPort('broker.hivemq.com', 'flutter_client', 1883);
  client.logging(on: true);

  client.onConnected = onConnected;
  client.onDisconnected = onDisconnected;
  client.onUnsubscribed = onUnsubscribed;
  client.onSubscribed = onSubscribed;
  client.onSubscribeFail = onSubscribeFail;
  client.pongCallback = pong;

  final connMessage = MqttConnectMessage()
      .withClientIdentifier('id')
      .authenticateAs('Michiel', 'MijnWachtwoord')
      .keepAliveFor(60)
      .withWillTopic('willtopic')
      .withWillMessage('Will message')
      .startClean()
      .withWillQos(MqttQos.atMostOnce);
  client.connectionMessage = connMessage;
  try {
    await client.connect();
  } catch (e) {
    print('Exception: $e');
    client.disconnect();
  }

  client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    final MqttPublishMessage message = c[0].payload;
    final payload =
    MqttPublishPayload.bytesToStringAsString(message.payload.message);

    print('Received message:$payload from topic: ${c[0].topic}>');
  });

  return client;
}

/// Connection succeeded.
void onConnected() {
  print('Connected');
}

/// Unconnected.
void onDisconnected() {
  print('Disconnected');
}

/// Subscribe to topic succeeded.
void onSubscribed(String topic) {
  print('Subscribed topic: $topic');
}

/// subscribe to topic failed.
void onSubscribeFail(String topic) {
  print('Failed to subscribe $topic');
}

/// Unsubscribe succeeded.
void onUnsubscribed(String topic) {
  print('Unsubscribed topic: $topic');
}

/// PING response received.
void pong() {
  print('Ping response client callback invoked');
}