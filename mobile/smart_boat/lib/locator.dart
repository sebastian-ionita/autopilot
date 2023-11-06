import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_boat/ble/ble_device_interactor.dart';
import 'package:smart_boat/services/message_handler.dart';
import 'package:smart_boat/services/message_sender.dart';
import 'package:smart_boat/ui/models/app_state.dart';

final locator = GetIt.I;

void initializeMessageHandler(AppState appState) {
  locator.registerSingleton<MessageHandlerService>(
      MessageHandlerService(appState: appState));
}

void initializeMessageSender(
    AppState appState,
    BleDeviceInteractor deviceInteractor,
    QualifiedCharacteristic characteristic) {
  locator.registerSingleton<MessageSenderService>(MessageSenderService(
      appState: appState,
      deviceInteractor: deviceInteractor,
      qualifiedCharacteristic: characteristic));
}
