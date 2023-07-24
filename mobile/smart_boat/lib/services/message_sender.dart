import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:smart_boat/ble/ble_device_interactor.dart';
import 'package:smart_boat/ui/models/app_state.dart';

class MessageSenderService {
  AppState appState;
  BleDeviceInteractor deviceInteractor;
  ConnectionStateUpdate connectionState;
  MessageSenderService(
      {required this.appState,
      required this.deviceInteractor,
      required this.connectionState});

  Future<void> sendMessage(String messageToSend) async {
    var discoveredServices =
        await deviceInteractor.discoverServices(connectionState.deviceId);
    for (var s in discoveredServices) {
      if (s.characteristics.isNotEmpty) {
        for (var c in s.characteristics) {
          if (c.isWritableWithoutResponse) {
            deviceInteractor.writeCharacterisiticWithoutResponse(
                QualifiedCharacteristic(
                    characteristicId: c.characteristicId,
                    serviceId: s.serviceId,
                    deviceId: connectionState.deviceId),
                messageToSend.codeUnits);
            return;
          }
        }
      }
    }
  }
}
