import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:print_color/print_color.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ble/ble_device_connector.dart';
import 'package:smart_boat/ui/base/ABottomSheet.dart';
import 'package:smart_boat/ui/base/AConfirmation.dart';
import 'package:smart_boat/ui/base/theme.dart';
import 'package:smart_boat/ui/base/utils/utils.dart';
import 'package:smart_boat/ui/ble_available_devices.dart';
import 'package:smart_boat/ui/ble_notallowed_screen.dart';
import 'package:smart_boat/ui/components/configuration_actions.dart';
import 'package:smart_boat/ui/components/data_received_indicator.dart';
import 'package:smart_boat/ui/components/live_data.dart';
import 'package:smart_boat/ui/components/received_messages.dart';
import 'package:smart_boat/ui/home_page.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import 'package:smart_boat/ui/new_base/ARoundedButton.dart';

class MainPageWidget extends StatefulWidget {
  const MainPageWidget({Key? key}) : super(key: key);

  @override
  _MainPageWidgetState createState() => _MainPageWidgetState();
}

class _MainPageWidgetState extends State<MainPageWidget>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //todo: tp be reviewed, should disconnect from bluetooth.
    if (state == AppLifecycleState.detached) {
      Print.red("App detached");
    }
    if (state == AppLifecycleState.inactive) {
      Print.red("App inactive");
    }
    if (state == AppLifecycleState.paused) {
      Print.red("App paused");
    }
    if (state == AppLifecycleState.resumed) {
      Print.red("App resumed");
    }
  }

  AppBar getAppBar(ConnectionStateUpdate connectionState,
      BleDeviceConnector deviceConnector, AppState appState) {
    var connected =
        connectionState.connectionState == DeviceConnectionState.connected;
    return AppBar(
      backgroundColor: SmartBoatTheme.of(context).primaryBackground,
      actions: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                child: ARoundedButton(
                    icon: Icon(
                      Icons.bluetooth,
                      color: SmartBoatTheme.of(context).thirdTextColor,
                      size: 18.0,
                    ),
                    type: connected
                        ? ARoundedButtonTypes.primary
                        : ARoundedButtonTypes.secondary,
                    buttonText: connected ? "Connected" : "Not Connected",
                    onLongPressed: () async {
                      if (connected) {
                        await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) {
                              return const ABottomSheet(
                                  height: 600, child: ReceivedMessagesWidget());
                            });
                      }
                    },
                    onPressed: () async {
                      if (connected) {
                        //disconnect boat
                        await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) {
                              return ABottomSheet(
                                  height: 250,
                                  child: AConfirmation(
                                      confirm: () async {
                                        deviceConnector.disconnect(
                                            connectionState.deviceId, appState);
                                        Utils.showSnack(
                                            SnackTypes.Info,
                                            "Successfully disconnected from boat!",
                                            context);
                                      },
                                      okText: "Yes, Disconnect",
                                      cancelText: "Not Now",
                                      title: "Disconnect the device",
                                      text:
                                          "This will stop was the boat is doing and it will return home. Are you sure you want this?"));
                            });
                      } else {
                        //show list of available devices
                        await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) {
                              return const ABottomSheet(
                                  height: 450, child: BleAvailableDevices());
                            });
                      }
                    }),
              ),
              connected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: SizedBox(
                          width: 110,
                          child: ARoundedButton(
                            icon: Icon(
                              Icons.data_exploration_outlined,
                              color: SmartBoatTheme.of(context).thirdTextColor,
                              size: 18.0,
                            ),
                            buttonText: 'Live data',
                            onLongPressed: () async {
                              await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return ABottomSheet(
                                        height: 800,
                                        child: ConfigurationSectionWidget());
                                  });
                            },
                            onPressed: () async {
                              await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return ABottomSheet(
                                        height: 500, child: LiveDataWidget());
                                  });
                            },
                            type: ARoundedButtonTypes.secondary,
                          )),
                    )
                  : const SizedBox(),
              connected ? DataReceivedIndicatorWidget() : const SizedBox()
            ],
          ),
        )
      ],
    );
  }

  BottomAppBar getBottomAppBar() {
    return BottomAppBar(
        child: Container(
      height: 60,
      color: SmartBoatTheme.of(context).primaryBackground,
    ));
  }

  Future<bool> _disconnectOnClose(BleDeviceConnector deviceConnector,
      ConnectionStateUpdate connectionStateUpdate, AppState appState) async {
    Print.red("Disconnecting from device, if connected");
    if (connectionStateUpdate.connectionState ==
        DeviceConnectionState.connected) {
      await deviceConnector.disconnect(
          connectionStateUpdate.deviceId, appState);
      appState.setListening(false);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) => Consumer4<BleStatus?,
          BleDeviceConnector, ConnectionStateUpdate, AppState>(
        builder: (_, status, deviceConnector, connectionState, appState, __) {
          return WillPopScope(
            onWillPop: () async {
              return await _disconnectOnClose(
                  deviceConnector, connectionState, appState);
            },
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: SmartBoatTheme.of(context).primaryBackground,
              appBar: getAppBar(connectionState, deviceConnector, appState),
              //bottomNavigationBar: getBottomAppBar(),
              body: SafeArea(
                child: Container(
                    child: (status == BleStatus.ready)
                        ? const HomePageWidget()
                        : BleNotAllowedScreen(
                            status: status ?? BleStatus.unknown)),
              ),
            ),
          );
        },
      );
}
