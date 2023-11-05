import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:print_color/print_color.dart';
import 'package:smart_boat/ble/ble_device_interactor.dart';
import 'package:smart_boat/ui/models/app_state.dart';

class MessageSenderService {
  AppState appState;
  BleDeviceInteractor deviceInteractor;
  ConnectionStateUpdate connectionState;
  late DiscoveredCharacteristic? characteristic = null;
  late DiscoveredService? service = null;

  static const int XON = 0x11; // ASCII code for XON (Resume transmission)
  static const int XOFF = 0x13; // ASCII code for XOFF (Pause transmission)

  MessageSenderService(
      {required this.appState,
      required this.deviceInteractor,
      required this.connectionState}) {
    initializeSendCharacteristic().then((value) {
      Print.cyan("Done initializing");
    });
  }

  List<String> splitMessage(String input) {
    List<String> result = [];
    int currentIndex = 0;

    while (currentIndex < input.length) {
      int endIndex = currentIndex + 10;
      if (endIndex > input.length) {
        endIndex = input.length;
      }

      String subString = input.substring(currentIndex, endIndex);
      result.add(subString);
      currentIndex = endIndex;
    }

    return result;
  }

  Future<void> initializeSendCharacteristic() async {
    var discoveredServices =
        await deviceInteractor.discoverServices(connectionState.deviceId);
    for (var s in discoveredServices) {
      service = s;
      if (s.characteristics.isNotEmpty) {
        for (var c in s.characteristics) {
          if (c.isWritableWithoutResponse) {
            Print.cyan(
                "Initializing characteristic for sending messages ${c.characteristicId}");
            characteristic = c;
          }
          if (c.isWritableWithResponse) {
            Print.magenta(c.characteristicId);
            characteristic = c;
          }
        }
      }
    }
    return;
  }

  Future<void> writeData(String data) async {
    await deviceInteractor.writeCharacterisiticWithoutResponse(
        QualifiedCharacteristic(
            characteristicId: characteristic!.characteristicId,
            serviceId: service!.serviceId,
            deviceId: connectionState.deviceId),
        data.codeUnits);
  }

  Future<void> stopBleTransmission() async {
    await writeData(String.fromCharCode(
        XOFF)); //send to arduino that it should stop sending data
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> startBleTransmission() async {
    await writeData(String.fromCharCode(XON));
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> sendMessage(String messageToSend,
      {bool stopTransmission = true}) async {
    if (service != null && characteristic != null) {
      messageToSend = "[$messageToSend]";
      Print.magenta("Message to send to the boat: $messageToSend");
      if (stopTransmission) {
        await stopBleTransmission();
      }
      //split message into multiple messages
      var messages = splitMessage(messageToSend);
      for (var m in messages) {
        while (!characteristic!.isWritableWithoutResponse) {
          Print.red("Not writable");
        }
        await writeData(m);
        await Future.delayed(const Duration(milliseconds: 300));
      }
      if (stopTransmission) {
        await startBleTransmission();
      }
    } else {
      Print.red("Characteristic is null");
    }
  }
}
