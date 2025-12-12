import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Constant {
  static const String broker = '10.178.23.219';
  static const int port = 1884;
  static const String username = '';
  static const String password = '';
}

class MqttService with ChangeNotifier {
  final String _broker = Constant.broker;
  final int _port = Constant.port;
  final String _username = Constant.username;
  final String _password = Constant.password;
  final String _topic = 'esp32/status';

  final String _clientId =
      'flutter_client_${DateTime.now().millisecondsSinceEpoch}';

  late MqttServerClient _client;
  String _currentStatus = "Disconnected";

  // Status Perangkat untuk UI
  bool _isDeviceOn = false;
  bool get isDeviceOn => _isDeviceOn;

  String get status => _currentStatus;

  Future<void> connect() async {
    _client = MqttServerClient(_broker, _clientId);
    _client.port = _port;

    _client.logging(on: true);

    _client.keepAlivePeriod = 60;

    _client.secure = false;

    _setupListeners();

    final connMessage = MqttConnectMessage()
        .withWillTopic('esp32/status') // Will topic
        .withWillMessage('0') // Kirim "0" jika mati mendadak
        .startClean() // Bersihkan sesi lama
        .withWillQos(MqttQos.atLeastOnce);

    // Hanya autentikasi jika username diisi
    if (_username.isNotEmpty) {
      connMessage.authenticateAs(_username, _password);
    }

    _client.connectionMessage = connMessage;

    try {
      _updateStatus("Connecting to Mosquitto...");
      await _client.connect();
    } catch (e) {
      _updateStatus("Connection failed: $e");
      _client.disconnect();
    }

    if (_client.updates != null) {
      _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final pt = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        if (c[0].topic == _topic) {
          if (pt.trim() == "1") {
            _isDeviceOn = true;
          } else {
            _isDeviceOn = false;
          }
          _updateStatus("Device Status: $pt");
        }

        log('RECEIVED MESSAGE: topic="${c[0].topic}", payload="$pt"');
        notifyListeners(); // Update UI
      });
    }
  }

  void disconnect() {
    _client.disconnect();
  }

  void _setupListeners() {
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
    _client.onSubscribeFail = _onSubscribeFail;
    _client.onUnsubscribed = _onUnsubscribed;
    _client.pongCallback = _pong;
  }

  void _updateStatus(String status) {
    _currentStatus = status;
    notifyListeners();
  }

  void _onConnected() {
    _updateStatus("Connected");
    log("connected to mqtt");
    _client.subscribe(_topic, MqttQos.atLeastOnce);
  }

  void _onDisconnected() {
    _updateStatus("Disconnected");
    _isDeviceOn = false; // Reset jadi offline
    notifyListeners();
  }

  void _onSubscribed(String topic) {
    _updateStatus("Subscribed to $topic");
  }

  void _onSubscribeFail(String topic) {
    _updateStatus("Failed to subscribe $topic");
  }

  void _onUnsubscribed(String? topic) {
    log('Unsubscribed topic: $topic');
  }

  void _pong() {
    log('Ping response client callback invoked');
  }
}
