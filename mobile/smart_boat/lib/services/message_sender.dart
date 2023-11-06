import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:print_color/print_color.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ble/ble_device_interactor.dart';
import 'package:smart_boat/ui/models/app_state.dart';

import '../locator.dart';
import 'message_handler.dart';

class MessageSenderService {
  AppState appState;
  BleDeviceInteractor deviceInteractor;
  QualifiedCharacteristic qualifiedCharacteristic;

  static const int XON = 0x11; // ASCII code for XON (Resume transmission)
  static const int XOFF = 0x13; // ASCII code for XOFF (Pause transmission)

  MessageSenderService(
      {required this.appState,
      required this.qualifiedCharacteristic,
      required this.deviceInteractor});

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

  Future<void> writeData(String data) async {
    await deviceInteractor.writeCharacterisiticWithoutResponse(
        qualifiedCharacteristic, data.codeUnits);
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
    messageToSend = "[$messageToSend]";
    Print.magenta("Message to send to the boat: $messageToSend");
    if (stopTransmission) {
      await stopBleTransmission();
    }
    //split message into multiple messages
    var messages = splitMessage(messageToSend);
    for (var m in messages) {
      await writeData(m);
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (stopTransmission) {
      await startBleTransmission();
    }
  }

  Future<void> startListening() async {
    var messageHandlerService = locator<MessageHandlerService>();

    deviceInteractor.subScribeToCharacteristic(qualifiedCharacteristic).listen(
        (event) {
      messageHandlerService.onMessageReceived(event);
    }, onError: (e) {
      Print.red("Error on characteristic subscription: $e");
    }, onDone: () async {
      Print.red("Characteristic is done: stopping connection");
      //await _stop(deviceId);
    }, cancelOnError: false);

    appState.setListening(true);
  }

  Future<void> readCharacteristic() async {
    var response =
        await deviceInteractor.readCharacteristic(qualifiedCharacteristic);
    Print.red(response);
  }
}
