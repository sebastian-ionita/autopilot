import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/theme.dart';
import 'package:smart_boat/ui/base/utils/utils.dart';
import 'package:smart_boat/ui/models/app_state.dart';

import '../ble/ble_device_connector.dart';
import '../ble/ble_scanner.dart';
import '../widgets.dart';

class BleAvailableDevices extends StatelessWidget {
  const BleAvailableDevices({Key? key}) : super(key: key);

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

  void connect(DiscoveredDevice device, AppState appState) async {
    try {
      widget.deviceConnector.connect(device.id, appState);
      Utils.showSnack(
          SnackTypes.Info, "Successfully connected to ${device.name}", context);
      Navigator.pop(context);
    } catch (e) {
      Utils.showSnack(
          SnackTypes.Info, "Connection to ${device.name} failed", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, appState, __) {
      return Scaffold(
        backgroundColor: SmartBoatTheme.of(context).secondaryBackground,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AText(
                text:
                    "Tap the FishingBoat device to connect to the fishing boat bluetooth module!",
                type: ATextTypes.small,
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: ListView(
                  children: [
                    Column(
                      children: widget.scannerState.discoveredDevices
                          .where((d) => d.name.isNotEmpty)
                          .map(
                            (device) => Container(
                              margin: const EdgeInsets.only(top: 5),
                              padding: const EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: ListTile(
                                title: AText(
                                  text: device.name,
                                  type: ATextTypes.normal,
                                  color: device.name.startsWith("Fishing")
                                      ? Colors.red
                                      : SmartBoatTheme.of(context).primaryText,
                                ),
                                subtitle: AText(
                                  text: "${device.id}\nRSSI: ${device.rssi}",
                                  type: ATextTypes.small,
                                ),
                                leading: const SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.bluetooth,
                                      )),
                                ),
                                trailing: const SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.chevron_right,
                                      )),
                                ),
                                onTap: () async {
                                  widget.stopScan();
                                  //connect to the selected device
                                  connect(device, appState);
                                },
                              ),
                            ),
                          )
                          .toList(),
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
