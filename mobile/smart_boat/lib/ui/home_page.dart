import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:print_color/print_color.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ble/ble_device_interactor.dart';
import 'package:smart_boat/services/message_handler.dart';
import 'package:smart_boat/ui/base/theme.dart';
import 'package:smart_boat/ui/components/main_header.dart';
import 'package:smart_boat/ui/components/map.dart';
import 'package:smart_boat/ui/models/app_state.dart';

import '../services/secure_storage_service.dart';
import 'components/actions_container.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late SecureStorageService secureStorageService;

  @override
  void initState() {
    super.initState();
  }

  void startListeningOnBluetooth(BleDeviceInteractor deviceInteractor,
      ConnectionStateUpdate bleConnectionStatus, AppState appState) {
    var messageHandlerService =
        MessageHandlerService(appState: appState, context: context);
    if (!appState.listening) {
      deviceInteractor
          .discoverServices(bleConnectionStatus.deviceId)
          .then((discoveredServices) {
        for (var s in discoveredServices) {
          if (s.characteristics.isNotEmpty) {
            for (var c in s.characteristics) {
              if (c.isWritableWithoutResponse && c.isReadable) {
                deviceInteractor
                    .subScribeToCharacteristic(QualifiedCharacteristic(
                        characteristicId: c.characteristicId,
                        serviceId: s.serviceId,
                        deviceId: bleConnectionStatus.deviceId))
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConnectionStateUpdate, AppState>(
        builder: (_, bleConnectionStatus, appState, __) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: SmartBoatTheme.of(context).secondaryBackground,
        child: Stack(
          children: [
            MapWidget(),
            Align(
              alignment: Alignment.topCenter,
              child: MainHeaderWidget(
                  connected: bleConnectionStatus.connectionState ==
                      DeviceConnectionState.connected),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: ActionsContainerWidget(
                  startListening: (BleDeviceInteractor deviceInteractor,
                      ConnectionStateUpdate connectionStatus) {
                    startListeningOnBluetooth(
                        deviceInteractor, connectionStatus, appState);
                  },
                  state: appState,
                ))
          ],
        ),
      );
    });
  }
}
