import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ble/ble_device_interactor.dart';
import 'package:smart_boat/services/message_sender.dart';
import 'package:smart_boat/ui/base/AButton.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/theme.dart';
import 'package:smart_boat/ui/models/app_state.dart';

class LiveDataWidget extends StatefulWidget {
  LiveDataWidget({Key? key}) : super(key: key);

  @override
  _LiveDataWidgetState createState() => _LiveDataWidgetState();
}

class _LiveDataWidgetState extends State<LiveDataWidget>
    with TickerProviderStateMixin {
  int counter = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AppState, BleDeviceInteractor, ConnectionStateUpdate>(
        builder: (_, appState, deviceInteractor, connectionStateUpdate, __) {
      return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: AText(
            type: ATextTypes.smallHeading,
            text: "Live data",
            color: SmartBoatTheme.of(context).primaryTextColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: AText(
            type: ATextTypes.normal,
            text: "Live data coming from the Fishing Boat",
            color: SmartBoatTheme.of(context).secondaryTextColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              AText(
                  type: ATextTypes.normal,
                  text: "Location: ",
                  color: SmartBoatTheme.of(context).secondaryTextColor),
              appState.boatLocation != null
                  ? AText(
                      type: ATextTypes.normal,
                      color: SmartBoatTheme.of(context).primaryTextColor,
                      text:
                          "LAT: ${appState.boatLocation!.latitude.toString()} LNG: ${appState.boatLocation!.longitude.toString()}")
                  : const SizedBox(),
            ],
          ),
        ),
        Divider(color: SmartBoatTheme.of(context).dividerColor),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              AText(
                  type: ATextTypes.normal,
                  text: "Point distance: ",
                  color: SmartBoatTheme.of(context).secondaryTextColor),
              appState.boatLiveData != null
                  ? AText(
                      type: ATextTypes.normal,
                      color: SmartBoatTheme.of(context).primaryTextColor,
                      text: appState.boatLiveData!.distance)
                  : const SizedBox(),
            ],
          ),
        ),
        Divider(color: SmartBoatTheme.of(context).dividerColor),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              AText(
                  type: ATextTypes.normal,
                  text: "Heading: ",
                  color: SmartBoatTheme.of(context).secondaryTextColor),
              appState.boatLiveData != null
                  ? AText(
                      type: ATextTypes.normal,
                      color: SmartBoatTheme.of(context).primaryTextColor,
                      text: appState.boatLiveData!.heading)
                  : const SizedBox(),
            ],
          ),
        ),
        Divider(color: SmartBoatTheme.of(context).dividerColor),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              AText(
                  type: ATextTypes.normal,
                  text: "Relative bearing: ",
                  color: SmartBoatTheme.of(context).secondaryTextColor),
              appState.boatLiveData != null
                  ? AText(
                      type: ATextTypes.normal,
                      color: SmartBoatTheme.of(context).primaryTextColor,
                      text: appState.boatLiveData!.relativeBearing)
                  : const SizedBox(),
            ],
          ),
        ),
        Divider(color: SmartBoatTheme.of(context).dividerColor),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              AText(
                  type: ATextTypes.normal,
                  text: "Rudder position: ",
                  color: SmartBoatTheme.of(context).secondaryTextColor),
              appState.boatLiveData != null
                  ? AText(
                      type: ATextTypes.normal,
                      color: SmartBoatTheme.of(context).primaryTextColor,
                      text: appState.boatLiveData!.rudderPosition)
                  : const SizedBox(),
            ],
          ),
        ),
        Divider(color: SmartBoatTheme.of(context).dividerColor),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              AText(
                type: ATextTypes.normal,
                text: "Main motor speed: ",
                color: SmartBoatTheme.of(context).secondaryTextColor,
              ),
              appState.boatLiveData != null
                  ? AText(
                      type: ATextTypes.normal,
                      color: SmartBoatTheme.of(context).primaryTextColor,
                      text: appState.boatLiveData!.motorSpeed)
                  : const SizedBox(),
            ],
          ),
        ),
        Divider(color: SmartBoatTheme.of(context).dividerColor),
      ]);
    });
  }
}
