import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/locator.dart';
import 'package:smart_boat/main_page.dart';
import 'package:smart_boat/services/secure_storage_service.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import 'package:smart_boat/ui/models/data_received_provider.dart';
import 'ble/ble_device_connector.dart';
import 'ble/ble_device_interactor.dart';
import 'ble/ble_logger.dart';
import 'ble/ble_scanner.dart';
import 'ble/ble_status_monitor.dart';

const _themeColor = Color.fromARGB(255, 74, 106, 195);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ble = FlutterReactiveBle();
  final bleLogger = BleLogger(ble: ble);
  final scanner = BleScanner(ble: ble, logMessage: bleLogger.addToLog);
  final monitor = BleStatusMonitor(ble);
  final serviceDiscoverer = BleDeviceInteractor(
    bleDiscoverServices: ble.discoverServices,
    readCharacteristic: ble.readCharacteristic,
    writeWithResponse: ble.writeCharacteristicWithResponse,
    writeWithOutResponse: ble.writeCharacteristicWithoutResponse,
    subscribeToCharacteristic: ble.subscribeToCharacteristic,
    logMessage: bleLogger.addToLog,
  );
  final connector = BleDeviceConnector(
    ble: ble,
    deviceInteractor: serviceDiscoverer,
    logMessage: bleLogger.addToLog,
  );

  var dataReceivedProvider = DataReceived();

  var secureStorageService = SecureStorageService();
  AppState appState;
  var appStateJson = await secureStorageService.getItem("appState");
  if (appStateJson.isNotEmpty) {
    appState = AppState.fromJson(jsonDecode(appStateJson));
  } else {
    appState = AppState(boatLocation: null, fishingTrips: []);
  }

  appState.setDataReceived(dataReceivedProvider);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: scanner),
        Provider.value(value: monitor),
        Provider.value(value: connector),
        Provider.value(value: serviceDiscoverer),
        Provider.value(value: bleLogger),
        ChangeNotifierProvider(create: (context) => dataReceivedProvider),
        StreamProvider<BleScannerState?>(
          create: (_) => scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),
        StreamProvider<BleStatus?>(
          create: (_) => monitor.state,
          initialData: BleStatus.unknown,
        ),
        StreamProvider<ConnectionStateUpdate>(
          create: (_) => connector.state,
          initialData: const ConnectionStateUpdate(
            deviceId: 'Unknown device',
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        ),
      ],
      child: ChangeNotifierProvider(
        create: (_) => appState,
        child: const MaterialApp(
          title: 'SmartBoat',
          color: _themeColor,
          home: MainPageWidget(),
        ),
      ),
    ),
  );
}
