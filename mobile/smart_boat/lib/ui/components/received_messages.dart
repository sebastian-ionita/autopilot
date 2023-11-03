import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/theme.dart';

import '../models/app_state.dart';

class ReceivedMessagesWidget extends StatefulWidget {
  const ReceivedMessagesWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ReceivedMessagesWidgetState createState() => _ReceivedMessagesWidgetState();
}

class _ReceivedMessagesWidgetState extends State<ReceivedMessagesWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  List<Widget> getMessagesList(List<String> messages) {
    return messages
        .asMap()
        .entries
        .map((entry) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: AText(
                    type: ATextTypes.small,
                    textAlign: TextAlign.start,
                    text: "[${entry.key}] - ${entry.value}",
                    color: SmartBoatTheme.of(context).primaryTextColor,
                  ),
                ),
                Divider(
                  color: SmartBoatTheme.of(context).dividerColor,
                )
              ],
            ))
        .toList()
        .reversed
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, appState, __) {
      return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 10),
          child: AText(
            type: ATextTypes.smallHeading,
            text: "Communication",
            color: SmartBoatTheme.of(context).primaryTextColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 10),
          child: AText(
            type: ATextTypes.normal,
            textAlign: TextAlign.center,
            text: "Messages sent from the boat",
            color: SmartBoatTheme.of(context).secondaryTextColor,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: getMessagesList(appState.infoMessages),
              ),
            ),
          ),
        )
      ]);
    });
  }
}
