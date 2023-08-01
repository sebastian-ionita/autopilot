import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ble/ble_device_connector.dart';
import 'package:smart_boat/ui/base/AConfirmation.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/theme.dart';
import 'package:smart_boat/ui/base/utils/utils.dart';
import 'package:smart_boat/ui/ble_available_devices.dart';
import 'package:smart_boat/ui/components/received_messages.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import '../base/ABottomSheet.dart';
import '../base/AIconButton.dart';
import 'live_data.dart';

class MainHeaderWidget extends StatefulWidget {
  final bool connected;
  const MainHeaderWidget({Key? key, required this.connected}) : super(key: key);

  @override
  _MainHeaderWidgetState createState() => _MainHeaderWidgetState();
}

class _MainHeaderWidgetState extends State<MainHeaderWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  Widget notConnectedToBoat() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: 15,
            ),
            child: AText(
              type: ATextTypes.small,
              text: "Not connected",
              color: SmartBoatTheme.of(context).secondaryText,
            ),
          ),
          AIconButton(
            borderColor: SmartBoatTheme.of(context).primaryBackground,
            borderRadius: 10,
            fillColor: SmartBoatTheme.of(context).primaryBackground,
            borderWidth: 1,
            icon: const Icon(
              Icons.bluetooth,
              color: Colors.red,
              size: 20,
            ),
            onPressed: () async {
              //show list of devices
              await showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) {
                    return const ABottomSheet(
                        height: 600, child: BleAvailableDevices());
                  });
            },
          )
        ]);
  }

  Widget connected(BleDeviceConnector deviceConnector,
      ConnectionStateUpdate bleState, AppState appState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              AIconButton(
                borderColor: SmartBoatTheme.of(context).primaryBackground,
                borderRadius: 10,
                fillColor: SmartBoatTheme.of(context).primaryBackground,
                borderWidth: 1,
                icon: const Icon(
                  Icons.home,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () async {
                  //show list of devices
                  await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return ABottomSheet(
                            height: 200,
                            child: AConfirmation(
                                confirm: () async {
                                  Utils.showSnack(SnackTypes.Info,
                                      "Boat will return home", context);
                                },
                                text:
                                    "This will stop was the boat is doing and it will return home. Are you sure you want this?"));
                      });
                },
              ),
              const SizedBox(width: 10),
              AIconButton(
                borderColor: SmartBoatTheme.of(context).primaryBackground,
                borderRadius: 10,
                fillColor: SmartBoatTheme.of(context).primaryBackground,
                borderWidth: 1,
                icon: const Icon(
                  Icons.directions_boat_sharp,
                  color: Colors.blue,
                  size: 20,
                ),
                onLongPressed: () async {
                  await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return const ABottomSheet(
                            height: 600, child: ReceivedMessagesWidget());
                      });
                },
                onPressed: () async {
                  //show list of devices
                  await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return ABottomSheet(
                            height: 500, child: LiveDataWidget());
                      });
                },
              )
            ],
          ),
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: AText(
                  type: ATextTypes.normal,
                  text: "Connected",
                  color: SmartBoatTheme.of(context).secondaryText,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
              ),
              AIconButton(
                borderColor: SmartBoatTheme.of(context).primaryBackground,
                borderRadius: 10,
                fillColor: SmartBoatTheme.of(context).primaryBackground,
                borderWidth: 1,
                icon: const Icon(
                  Icons.bluetooth,
                  color: Colors.green,
                  size: 20,
                ),
                onLongPressed: () async {
                  await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return const ABottomSheet(
                            height: 600, child: ReceivedMessagesWidget());
                      });
                },
                onPressed: () async {
                  //show list of devices
                  await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return ABottomSheet(
                            height: 200,
                            child: AConfirmation(
                                confirm: () async {
                                  deviceConnector.disconnect(
                                      bleState.deviceId, appState);
                                  appState.setListening(false);
                                  Utils.showSnack(
                                      SnackTypes.Info,
                                      "Successfully disconnected from boat!",
                                      context);
                                },
                                title: "Disconnect",
                                text:
                                    "Are you sure you want to disconnect from the fishing boat?"));
                      });
                },
              )
            ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) =>
      Consumer3<BleDeviceConnector, ConnectionStateUpdate, AppState>(
          builder: (_, deviceConnector, bleState, appState, __) {
        return FractionallySizedBox(
          heightFactor: 0.12,
          child: Container(
            width: double.infinity,
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 20, top: 20, bottom: 10),
                child: widget.connected
                    ? connected(deviceConnector, bleState, appState)
                    : notConnectedToBoat(),
              ),
            ),
          ),
        );
      });
}
