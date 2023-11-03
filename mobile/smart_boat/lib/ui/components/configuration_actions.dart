import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ble/ble_device_interactor.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/ATextField/ATextField.dart';
import 'package:smart_boat/ui/base/theme.dart';
import 'package:smart_boat/ui/base/utils/utils.dart';
import 'package:smart_boat/ui/models/app_state.dart';

import '../../services/message_sender.dart';
import '../base/AButton.dart';

class ConfigurationSectionWidget extends StatefulWidget {
  ConfigurationSectionWidget({Key? key}) : super(key: key);

  @override
  _ConfigurationSectionWidgetState createState() =>
      _ConfigurationSectionWidgetState();
}

class _ConfigurationSectionWidgetState extends State<ConfigurationSectionWidget>
    with TickerProviderStateMixin {
  late TextEditingController messageController;
  @override
  void initState() {
    messageController = TextEditingController();
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
            text: "Configuration",
            color: SmartBoatTheme.of(context).primaryTextColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: AText(
            type: ATextTypes.normal,
            textAlign: TextAlign.center,
            text:
                "Few small actions to perform on the boat, only for debugging purposes.",
            color: SmartBoatTheme.of(context).secondaryTextColor,
          ),
        ),
        Divider(color: SmartBoatTheme.of(context).dividerColor),
        Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            children: [
              AButton(
                  type: AButtonTypes.primary,
                  buttonText: "XOFF",
                  onPressed: () async {
                    var messageSenderService = MessageSenderService(
                        appState: appState,
                        deviceInteractor: deviceInteractor,
                        connectionState: connectionStateUpdate);

                    await messageSenderService.initializeSendCharacteristic();
                    for (int i = 0; i < 3; i++) {
                      await messageSenderService.sendMessage("XOFF*");
                    }
                  }),
              const SizedBox(width: 5),
              AButton(
                  type: AButtonTypes.primary,
                  buttonText: "XON",
                  onPressed: () async {
                    var messageSenderService = MessageSenderService(
                        appState: appState,
                        deviceInteractor: deviceInteractor,
                        connectionState: connectionStateUpdate);

                    await messageSenderService.initializeSendCharacteristic();
                    for (int i = 0; i < 3; i++) {
                      await messageSenderService.sendMessage("XON*");
                    }
                  }),
            ],
          ),
        ),
        Divider(color: SmartBoatTheme.of(context).dividerColor),
        Divider(color: SmartBoatTheme.of(context).dividerColor),
        Divider(color: SmartBoatTheme.of(context).dividerColor),
        Divider(color: SmartBoatTheme.of(context).dividerColor),
        Divider(color: SmartBoatTheme.of(context).dividerColor),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ATextField(
              type: ATextFieldTypes.text,
              controller: messageController,
              label: "Message",
              placeholder: "Type something"),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AButton(
                  type: AButtonTypes.primary,
                  buttonText: "Send to boat",
                  onPressed: () async {
                    if (messageController.text.isEmpty) {
                      Utils.showSnack(SnackTypes.Info,
                          "Please type something on the message box.", context);
                      return;
                    }
                    var messageSenderService = MessageSenderService(
                        appState: appState,
                        deviceInteractor: deviceInteractor,
                        connectionState: connectionStateUpdate);
                    await messageSenderService.initializeSendCharacteristic();
                    await messageSenderService
                        .sendMessage(messageController.text);
                  })
            ],
          ),
        ),
      ]);
    });
  }
}
