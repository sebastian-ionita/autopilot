import 'package:get_it/get_it.dart';
import 'package:smart_boat/ble/ble_device_connector.dart';
import 'package:smart_boat/ble/ble_device_interactor.dart';
import 'package:smart_boat/services/message_handler.dart';
import 'package:smart_boat/ui/models/app_state.dart';

final locator = GetIt.I;
void setupLocator(AppState appState, BleDeviceConnector deviceConnector,
    BleDeviceInteractor deviceInteractor) {
  locator.registerSingleton<MessageHandlerService>(MessageHandlerService(
      appState: appState, deviceInteractor: deviceInteractor));
}
