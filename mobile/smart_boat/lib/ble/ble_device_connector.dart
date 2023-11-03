import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:print_color/print_color.dart';
import 'package:smart_boat/ble/ble_device_interactor.dart';
import 'package:smart_boat/ble/reactive_state.dart';
import 'package:smart_boat/ui/models/app_state.dart';

import '../services/message_handler.dart';

class BleDeviceConnector extends ReactiveState<ConnectionStateUpdate> {
  BleDeviceConnector({
    required FlutterReactiveBle ble,
    required BleDeviceInteractor deviceInteractor,
    required Function(String message) logMessage,
  })  : _ble = ble,
        _deviceInteractor = deviceInteractor,
        _logMessage = logMessage;

  final FlutterReactiveBle _ble;
  final BleDeviceInteractor _deviceInteractor;
  final void Function(String message) _logMessage;

  @override
  Stream<ConnectionStateUpdate> get state => _deviceConnectionController.stream;

  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();

  // ignore: cancel_subscriptions
  late StreamSubscription<ConnectionStateUpdate> _connection;

  Future<void> _startListening(String deviceId, AppState appState) async {
    var messageHandlerService = MessageHandlerService(
        appState: appState, deviceInteractor: _deviceInteractor);
    _deviceInteractor.discoverServices(deviceId).then((discoveredServices) {
      for (var s in discoveredServices) {
        if (s.characteristics.isNotEmpty) {
          for (var c in s.characteristics) {
            if (c.isWritableWithoutResponse && c.isReadable) {
              _deviceInteractor
                  .subScribeToCharacteristic(QualifiedCharacteristic(
                      characteristicId: c.characteristicId,
                      serviceId: s.serviceId,
                      deviceId: deviceId))
                  .listen((event) {
                messageHandlerService.onMessageReceived(event);
              });
              appState.setListening(true);
              Print.green("Listening started successfully");
              return;
            }
          }
        }
      }
    });
  }

  Future<void> connect(
    String deviceId,
    AppState appState,
  ) async {
    _logMessage('Start connecting to $deviceId');
    _connection = _ble.connectToDevice(id: deviceId).listen(
      (update) async {
        if (update.connectionState == DeviceConnectionState.disconnected) {
          appState.setListening(false);
        }
        if (update.connectionState == DeviceConnectionState.connected) {
          await Future.delayed(const Duration(
              seconds: 1)); //wait one second before starting to listen
          await _startListening(deviceId, appState);
          if (appState.fishingTrips.isNotEmpty) {
            //set first fishing trip selected
            //set selected fishing trip and update state
            appState.setSelectedFishingTrip(appState.fishingTrips.first);
          }
        }
        _logMessage(
            'ConnectionState for device $deviceId : ${update.connectionState}');
        _deviceConnectionController.add(update);
      },
      onError: (Object e) =>
          _logMessage('Connecting to device $deviceId resulted in error $e'),
    );
  }

  Future<void> disconnect(String deviceId, AppState appState) async {
    try {
      _logMessage('disconnecting to device: $deviceId');
      await _connection.cancel();
      appState.setSelectedFishingTrip(null);
    } on Exception catch (e, _) {
      _logMessage("Error disconnecting from a device: $e");
    } finally {
      // Since [_connection] subscription is terminated, the "disconnected" state cannot be received and propagated
      _deviceConnectionController.add(
        ConnectionStateUpdate(
          deviceId: deviceId,
          connectionState: DeviceConnectionState.disconnected,
          failure: null,
        ),
      );
    }
  }

  Future<void> dispose() async {
    await _deviceConnectionController.close();
  }
}
