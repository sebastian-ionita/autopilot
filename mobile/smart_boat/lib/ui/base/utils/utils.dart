import 'package:flutter/material.dart';
import '../AText.dart';

enum SnackTypes { Info, Error }

class Utils {
  static SnackBar getSnack(String snackText, BuildContext context) {
    return snack(snackText, "success", context);
  }

  static SnackBar getErrorSnack(String snackText, BuildContext context) {
    return snack(snackText, "error", context);
  }

  static void showSnack(SnackTypes type, String snackText, BuildContext context,
      {bool? removeExisting}) {
    SnackBar snackBar;
    switch (type) {
      case SnackTypes.Error:
        {
          snackBar = getErrorSnack(snackText, context);
          break;
        }
      case SnackTypes.Info:
        {
          snackBar = getSnack(snackText, context);
          break;
        }
    }
    if (removeExisting != null && removeExisting) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
    }
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static double round(double value, int nrDecimals) {
    var roundedString = value.toStringAsFixed(nrDecimals);
    return double.parse(roundedString);
  }

  static double spaceDependingOnWidth(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    if (deviceWidth <= 380) {
      return 20.0;
    }
    if (deviceWidth <= 400) {
      return 35.0;
    } else {
      return 60.0;
    }
  }

  static Color getStatusColor(int billingStatus) {
    switch (billingStatus) {
      case 0:
        return const Color(0xFFFB3CBA);
      case 1:
        return const Color(0xFFFBD408);
      case 2:
        return const Color(0xFF07D003);
      case 3:
        return const Color(0xFF14B8C2);
      case 4:
        return const Color(0xFF6114C2);
      case 4:
        return const Color(0xFF145AC2);
    }

    return const Color(0xFF5A1BDA);
  }

  static SnackBar snack(String snackText, String type, BuildContext context) {
    return SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black,
        content: AText(
            type: ATextTypes.small,
            text: snackText,
            color: type == "success" ? Colors.white : Colors.red));
  }

  static getAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now().toLocal();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  static TimeOfDay getTimeDiference(TimeOfDay start, TimeOfDay end) {
    bool _pmToAm = false;
    if (start.period == DayPeriod.pm && end.period == DayPeriod.am)
      _pmToAm = true;

    int _startTimeMin = start.hour * 60 + start.minute;
    int _endTimeMin = (_pmToAm ? end.hour + 24 : end.hour) * 60 + end.minute;

    int _timeDiff = _endTimeMin - _startTimeMin;

    int _hr = (_timeDiff / 60).truncate();
    int _minute = (_timeDiff - (_hr * 60).truncate()).toInt();

    if (_hr <= 0) _hr = 24 + _hr;
    if (_hr == 24) _hr = 0;
    if (_minute < 0) {
      _minute = 60 + _minute;
      _hr--;
    }

    return TimeOfDay(hour: _hr, minute: _minute);
  }

  static getQuickInfoIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
                getSnack("Long press code item to see more details", context));
          },
          child: const Icon(
            Icons.info,
            size: 18,
          )),
    );
  }
}

class TimeUtils {
  static bool timeInRange(String shortTitle, double time) {
    //replace text and spaces in the string
    try {
      shortTitle = shortTitle.split("(")[0];

      shortTitle = shortTitle
          .replaceAll("HOURS", "")
          .replaceAll("HOUR", "")
          .replaceAll("MINUTES", "")
          .replaceAll("OR", "")
          .replaceAll("LESS", "")
          .replaceAll("hours", "")
          .replaceAll("minutes", "")
          .replaceAll("to", "")
          .replaceAll("TO", "")
          .replaceAll("   ", " ");
      var ranges = shortTitle.split(" ");
      var start = getMinutesFromHour(ranges[0]);
      var end = getMinutesFromHour(ranges[1]);
      if (end == 0) {
        if (time <= start) return true;
      }
      return start <= time && double.parse(time.toStringAsFixed(0)) <= end;
    } catch (e) {
      return false;
    }
  }

  static double getBigIntervalHours(String shortTitle) {
    //replace text and spaces in the string
    try {
      shortTitle = shortTitle.split("(")[0];
      //remove string from short title
      shortTitle = shortTitle
          .replaceAll("HOURS", "")
          .replaceAll("HOUR", "")
          .replaceAll("MINUTES", "")
          .replaceAll("OR", "")
          .replaceAll("LESS", "")
          .replaceAll("hours", "")
          .replaceAll("minutes", "")
          .replaceAll("to", "")
          .replaceAll("TO", "")
          .replaceAll("   ", " ");

      var ranges = shortTitle.split(" ");
      var start = getMinutesFromHour(ranges[0]);
      var end = getMinutesFromHour(ranges[1]);
      if (end == 0) {
        return start / 60; //get minimum interval in hours
      }
      return end / 60;
    } catch (e) {
      return 0;
    }
  }

  static int getMinutesFromHour(String value) {
    try {
      if (!value.contains(":")) {
        return int.parse(value);
      }
      var parts = value.split(":");
      var hour = parts[0];
      var minute = parts[1];
      var hourInt = int.tryParse(hour);
      var minuteInt = int.tryParse(minute);
      if (minuteInt != null && hourInt != null) return minuteInt + hourInt * 60;
      return 0;
    } catch (e) {
      return 0;
    }
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
