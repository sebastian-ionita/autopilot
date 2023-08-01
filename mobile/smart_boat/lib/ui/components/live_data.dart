import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ble/ble_device_interactor.dart';
import 'package:smart_boat/services/message_sender.dart';
import 'package:smart_boat/ui/base/AButton.dart';
import 'package:smart_boat/ui/base/AText.dart';
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
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AText(type: ATextTypes.heading, text: "Live data"),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AText(type: ATextTypes.normal, text: "Location: "),
              appState.boatLocation != null
                  ? AText(
                      type: ATextTypes.normal,
                      text:
                          "LAT: ${appState.boatLocation!.latitude.toString()} LNG: ${appState.boatLocation!.longitude.toString()}")
                  : const SizedBox(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AText(type: ATextTypes.normal, text: "Point distance: "),
              appState.boatLiveData != null
                  ? AText(
                      type: ATextTypes.normal,
                      text: appState.boatLiveData!.distance)
                  : const SizedBox(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AText(type: ATextTypes.normal, text: "Heading: "),
              appState.boatLiveData != null
                  ? AText(
                      type: ATextTypes.normal,
                      text: appState.boatLiveData!.heading)
                  : const SizedBox(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AText(type: ATextTypes.normal, text: "Relative bearing: "),
              appState.boatLiveData != null
                  ? AText(
                      type: ATextTypes.normal,
                      text: appState.boatLiveData!.relativeBearing)
                  : const SizedBox(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AText(type: ATextTypes.normal, text: "Rudder position: "),
              appState.boatLiveData != null
                  ? AText(
                      type: ATextTypes.normal,
                      text: appState.boatLiveData!.rudderPosition)
                  : const SizedBox(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AText(type: ATextTypes.normal, text: "Main motor speed: "),
              appState.boatLiveData != null
                  ? AText(
                      type: ATextTypes.normal,
                      text: appState.boatLiveData!.motorSpeed)
                  : const SizedBox(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AButton(
                  type: AButtonTypes.primary,
                  buttonText: "Send to bluetooth",
                  onPressed: () async {
                    var messageSenderService = MessageSenderService(
                        appState: appState,
                        deviceInteractor: deviceInteractor,
                        connectionState: connectionStateUpdate);
                    await messageSenderService.initializeSendCharacteristic();
                    await messageSenderService.sendMessage(
                        "$counter Small message but a bit bigger that the other requesteddf ffsd f sf ssdfsd END EVEN A BIGGER ONE SMFM");
                    setState(() {
                      counter = counter + 1;
                    });
                  })
            ],
          ),
        ),
      ]);
    });
  }
}
