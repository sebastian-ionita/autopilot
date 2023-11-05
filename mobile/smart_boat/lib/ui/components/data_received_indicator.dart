import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/theme.dart';

import '../models/data_received_provider.dart';

class DataReceivedIndicatorWidget extends StatefulWidget {
  DataReceivedIndicatorWidget({Key? key}) : super(key: key);

  @override
  _DataReceivedIndicatorWidgetState createState() =>
      _DataReceivedIndicatorWidgetState();
}

class _DataReceivedIndicatorWidgetState
    extends State<DataReceivedIndicatorWidget> {
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
    final dataReceivedModel = context.watch<DataReceived>();

    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: dataReceivedModel.dataReceived
                      ? Colors.white
                      : SmartBoatTheme.of(context).primaryButtonDisabledColor,
                  blurRadius: 4.0,
                ),
              ],
              color: SmartBoatTheme.of(context).roundedButtonSecondary),
          child: const SizedBox()),
    );
  }
}
