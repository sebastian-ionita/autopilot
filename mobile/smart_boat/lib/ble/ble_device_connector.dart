import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:print_color/print_color.dart';
import 'package:smart_boat/ble/ble_device_interactor.dart';
import 'package:smart_boat/ble/reactive_state.dart';
import 'package:smart_boat/ui/models/app_state.dart';

import '../locator.dart';
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

  StreamSubscription? characteristicSubscription;

  @override
  Stream<ConnectionStateUpdate> get state => _deviceConnectionController.stream;

  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();

  // ignore: cancel_subscriptions
  late StreamSubscription<ConnectionStateUpdate>? _connection;

  Future<void> _startListening(String deviceId, AppState appState,
      BleDeviceInteractor deviceInteractor) async {
    try {
      var messageHandlerService = locator<MessageHandlerService>();
      _deviceInteractor
          .discoverServices(deviceId)
          .then((discoveredServices) async {
        for (var s in discoveredServices) {
          if (s.characteristics.isNotEmpty) {
            for (var c in s.characteristics) {
              if (c.isWritableWithoutResponse) {
                await characteristicSubscription?.cancel();
                await Future.delayed(const Duration(milliseconds: 500));
                Print.magenta("Start listening on ${c.characteristicId}");
                characteristicSubscription = _deviceInteractor
                    .subScribeToCharacteristic(QualifiedCharacteristic(
                        characteristicId: c.characteristicId,
                        serviceId: s.serviceId,
                        deviceId: deviceId))
                    .listen((event) {
                  messageHandlerService.onMessageReceived(event);
                }, onError: (e) {
                  Print.red("Error on characteristic subscription: $e");
                }, onDone: () async {
                  Print.red("Characteristic is done: stopping connection");
                  await _stop(deviceId);
                }, cancelOnError: false);

                appState.setListening(true);
                Print.green("Listening started successfully");
                return;
              }
            }
          }
        }
      });
    } catch (e) {
      Print.red("Exception on start listening");
    }
  }

  Future<void> connect(
    String deviceId,
    BleDeviceInteractor deviceInteractor,
    AppState appState,
  ) async {
    _logMessage('Start connecting to $deviceId');
    _connection = _ble.connectToDevice(id: deviceId).listen(
      (update) async {
        if (update.connectionState == DeviceConnectionState.disconnected) {
          Print.red("App disconnected from remote");
          appState.setListening(false);
          locator.reset();
        }
        if (update.connectionState == DeviceConnectionState.connected) {
          await Future.delayed(const Duration(
              seconds: 1)); //wait one second before starting to listen

          initializeMessageSender(appState, deviceInteractor, update);
          initializeMessageHandler(appState, deviceInteractor);

          await _startListening(deviceId, appState, deviceInteractor);

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
      appState.setListening(false);
      await _connection?.cancel();
      _connection = null;
      await characteristicSubscription?.cancel();
      characteristicSubscription = null;
      locator.reset();
      //appState.setSelectedFishingTrip(null);
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

  Future<void> _stop(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    await characteristicSubscription?.cancel();
    characteristicSubscription = null;

    await Future.delayed(const Duration(milliseconds: 500));

    await _connection?.cancel();
    _connection = null;

    _deviceConnectionController.add(
      ConnectionStateUpdate(
        deviceId: deviceId,
        connectionState: DeviceConnectionState.disconnected,
        failure: null,
      ),
    );
  }

  Future<void> dispose() async {
    await _deviceConnectionController.close();
  }
}
