import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/ATextField/ATextField.dart';
import 'package:smart_boat/ui/base/theme.dart';
import 'package:smart_boat/ui/base/utils/utils.dart';
import 'package:smart_boat/ui/models/app_state.dart';

import '../../locator.dart';
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
    return Consumer<AppState>(builder: (_, appState, __) {
      return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
                      var messageSender = locator<MessageSenderService>();
                      //await messageSender.initializeSendCharacteristic();
                      for (int i = 0; i < 3; i++) {
                        await messageSender.sendMessage("XOFF*",
                            stopTransmission: false);
                      }
                    }),
                const SizedBox(width: 5),
                AButton(
                    type: AButtonTypes.primary,
                    buttonText: "XON",
                    onPressed: () async {
                      var messageSender = locator<MessageSenderService>();
                      //await messageSender.initializeSendCharacteristic();
                      for (int i = 0; i < 3; i++) {
                        await messageSender.sendMessage("XON*",
                            stopTransmission: false);
                      }
                    }),
                const SizedBox(width: 5),
                AButton(
                    type: AButtonTypes.primary,
                    buttonText: "XOFF B",
                    onPressed: () async {
                      var messageSender = locator<MessageSenderService>();
                      await messageSender.stopBleTransmission();
                    }),
                const SizedBox(width: 5),
                AButton(
                    type: AButtonTypes.primary,
                    buttonText: "XON B",
                    onPressed: () async {
                      var messageSender = locator<MessageSenderService>();
                      await messageSender.startBleTransmission();
                    }),
              ],
            ),
          ),
          Divider(color: SmartBoatTheme.of(context).dividerColor),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Row(
              children: [
                AButton(
                    type: AButtonTypes.primary,
                    buttonText: "Load config",
                    onPressed: () async {
                      var messageSender = locator<MessageSenderService>();
                      await messageSender.sendMessage("GETC*");
                    }),
                const SizedBox(width: 5),
                AButton(
                    type: AButtonTypes.primary,
                    buttonText: "Empty",
                    onPressed: () async {}),
              ],
            ),
          ),
          Divider(color: SmartBoatTheme.of(context).dividerColor),
          appState.boatConfig != null
              ? Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Row(
                    children: [
                      AText(
                          type: ATextTypes.small,
                          text:
                              "Boat config: Proximity: ${appState.boatConfig!.proximity} Rudder Offset: ${appState.boatConfig!.rudderOffset} Rudder delay: ${appState.boatConfig!.rudderOffset}")
                    ],
                  ),
                )
              : const SizedBox(),
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
                        Utils.showSnack(
                            SnackTypes.Info,
                            "Please type something on the message box.",
                            context);
                        return;
                      }
                      var messageSender = locator<MessageSenderService>();
                      //await messageSender.readCharacteristic();
                      await messageSender.sendMessage(messageController.text,
                          stopTransmission: false);
                    })
              ],
            ),
          ),
        ]),
      );
    });
  }
}
