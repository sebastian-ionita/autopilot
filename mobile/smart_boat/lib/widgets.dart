import 'package:flutter/material.dart';
import 'package:smart_boat/ui/base/theme.dart';

class BluetoothIcon extends StatelessWidget {
  const BluetoothIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 44,
        height: 44,
        child: Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.bluetooth,
              color: SmartBoatTheme.of(context).secondaryText,
            )),
      );
}

class StatusMessage extends StatelessWidget {
  const StatusMessage({
    required this.text,
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );
}
