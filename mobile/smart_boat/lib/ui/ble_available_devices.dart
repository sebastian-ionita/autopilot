// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:print_color/print_color.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/theme.dart';
import 'package:smart_boat/ui/base/utils/utils.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import '../ble/ble_device_connector.dart';
import '../ble/ble_device_interactor.dart';
import '../ble/ble_scanner.dart';
import '../locator.dart';
import '../services/message_handler.dart';

class BleAvailableDevices extends StatelessWidget {
  const BleAvailableDevices({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Consumer3<BleScanner, BleScannerState?, BleDeviceConnector>(
        builder: (_, bleScanner, bleScannerState, deviceConnector, __) =>
            _DeviceList(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
          deviceConnector: deviceConnector,
        ),
      );
}

class _DeviceList extends StatefulWidget {
  const _DeviceList(
      {required this.scannerState,
      required this.startScan,
      required this.stopScan,
      required this.deviceConnector});

  final BleScannerState scannerState;
  final BleDeviceConnector deviceConnector;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<_DeviceList> {
  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  @override
  void dispose() {
    widget.stopScan();
    super.dispose();
  }

  void _startScanning() {
    widget.startScan([]);
  }

  Future<void> connect(
      DiscoveredDevice device,
      BleDeviceInteractor deviceInteractor,
      ConnectionStateUpdate connectionStateUpdate,
      AppState appState) async {
    try {
      await widget.deviceConnector
          .connect(device.id, deviceInteractor, appState);
      Utils.showSnack(
          SnackTypes.Info, "Successfully connected to ${device.name}", context);
    } catch (e) {
      Utils.showSnack(
          SnackTypes.Info, "Connection to ${device.name} failed", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AppState, BleDeviceInteractor, ConnectionStateUpdate>(
        builder: (_, appState, deviceInteractor, connectionStateUpdate, __) {
      return Container(
        color: SmartBoatTheme.of(context).primaryBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 10),
              child: AText(
                text: "Available bluetooth devices",
                type: ATextTypes.smallHeading,
                color: SmartBoatTheme.of(context).primaryTextColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 10, top: 10, left: 10, right: 10),
              child: AText(
                textAlign: TextAlign.center,
                text:
                    "Tap the FishingBoat device to connect to the fishing boat bluetooth module!",
                type: ATextTypes.normal,
                color: SmartBoatTheme.of(context).secondaryTextColor,
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        children: widget.scannerState.discoveredDevices
                            .where((d) => d.name.isNotEmpty)
                            .map(
                              (device) => Column(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: ListTile(
                                      title: AText(
                                        text: device.name,
                                        type: ATextTypes.normal,
                                        color: SmartBoatTheme.of(context)
                                            .primaryTextColor,
                                      ),
                                      leading: SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.bluetooth,
                                              color: SmartBoatTheme.of(context)
                                                  .primaryTextColor,
                                            )),
                                      ),
                                      trailing: SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.chevron_right,
                                              color: SmartBoatTheme.of(context)
                                                  .primaryTextColor,
                                            )),
                                      ),
                                      onTap: () async {
                                        widget.stopScan();
                                        //connect to the selected device
                                        await connect(device, deviceInteractor,
                                            connectionStateUpdate, appState);

                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                  Divider(
                                    color:
                                        SmartBoatTheme.of(context).dividerColor,
                                  )
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
