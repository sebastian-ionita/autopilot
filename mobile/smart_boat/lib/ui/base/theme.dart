// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';

abstract class SmartBoatTheme {
  static SmartBoatTheme of(BuildContext context) {
    return LightModeTheme();
  }

  late Color primaryColor;
  late Color primaryButtonColor;
  late Color primaryButtonDisabledColor;
  late Color secondaryColor;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color primaryText;
  late Color secondaryText;
  late Color lineColor;

  late Color roundedButtonPrimary;
  late Color roundedButtonSecondary;
  late Color secondaryTextColor;
  late Color primaryTextColor;
  late Color thirdTextColor;
  late Color dividerColor;
  late Color selectedTextColor;
}

class LightModeTheme extends SmartBoatTheme {
  late Color primaryButtonColor = const Color(0xFF367ADF);
  late Color primaryButtonDisabledColor = const Color(0xFF313841);

  late Color primaryColor = const Color(0xFF3C006B);
  late Color secondaryColor = const Color(0xFF5A1BDA);
  late Color secondaryBackground = const Color.fromARGB(255, 255, 255, 255);
  late Color primaryText = const Color.fromARGB(255, 0, 0, 0);
  late Color secondaryText = const Color.fromARGB(255, 255, 255, 255);
  late Color lineColor = const Color.fromARGB(255, 52, 51, 51);

  late Color primaryBackground = const Color(0xFF111820);
  late Color roundedButtonPrimary = const Color(0xFF9BC910);
  late Color roundedButtonSecondary = const Color(0xFF8A919C);

  late Color secondaryTextColor = const Color(0xFF8A919C);
  late Color primaryTextColor = const Color(0xFFF0F9FF);
  late Color thirdTextColor = const Color(0xFF111820);
  late Color selectedTextColor = const Color(0xFF367ADF);

  late Color dividerColor = const Color(0xFF313841);
}
