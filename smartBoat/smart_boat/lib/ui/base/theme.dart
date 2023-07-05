// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';

abstract class SmartBoatTheme {
  static SmartBoatTheme of(BuildContext context) {
    return LightModeTheme();
  }

  late Color primaryColor;
  late Color primaryButtonColor;
  late Color secondaryColor;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color primaryText;
  late Color secondaryText;
  late Color lineColor;
}

class LightModeTheme extends SmartBoatTheme {
  late Color primaryButtonColor = const Color(0xFF5A1BDA);
  late Color primaryColor = const Color(0xFF3C006B);
  late Color secondaryColor = const Color(0xFF5A1BDA);
  late Color primaryBackground = Color.fromARGB(255, 226, 228, 226);
  late Color secondaryBackground = Color.fromARGB(255, 255, 255, 255);
  late Color primaryText = Color.fromARGB(255, 0, 0, 0);
  late Color secondaryText = const Color.fromARGB(255, 255, 255, 255);
  late Color lineColor = const Color.fromARGB(255, 52, 51, 51);
}
