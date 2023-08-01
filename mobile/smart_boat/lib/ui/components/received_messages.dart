import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/AText.dart';

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
        .map((entry) => AText(
            type: ATextTypes.small, text: "[${entry.key}] - ${entry.value}"))
        .toList()
        .reversed
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, appState, __) {
      return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: AText(type: ATextTypes.normal, text: "Received messages"),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: getMessagesList(appState.infoMessages),
              ),
            ),
          )
        ]),
      );
    });
  }
}
