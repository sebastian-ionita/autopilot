import 'package:flutter/material.dart';

class Validators {
  static String? dateTimeValidator(String? value) {
    if (value == null) return null;
    final components = value.split("/");
    if (components.length == 3) {
      final day = int.tryParse(components[0]);
      final month = int.tryParse(components[1]);
      final year = int.tryParse(components[2]);
      if (day != null && month != null && year != null) {
        if (year.toString().length < 4) return "Invalid year";
        var yearDif = DateTime.now().year - year;
        if (yearDif.abs() > 110) return "Invalid year";
        final date = DateTime(year, month, day);
        if (date.year != year || date.month != month || date.day != day) {
          return "Invalid date";
        }
      } else {
        return "Invalid date";
      }
    } else {
      return "Invalid date";
    }
    return null;
  }

  static String? timeValidator(String? value) {
    if (value == null) return null;
    final components = value.split(":");
    if (components.length == 2) {
      final hour = int.tryParse(components[0]);
      final minute = int.tryParse(components[1]);
      if (hour != null && minute != null) {
        if (hour < 0 || hour > 24) return "Invalid hour";
        if (minute < 0 || minute > 59) return "Invalid minute";
        final timeOfDay = TimeOfDay(hour: hour, minute: minute);
        if (timeOfDay.hour != hour || timeOfDay.minute != minute) {
          return "Invalid time";
        }
      } else {
        return "Invalid time";
      }
    } else {
      return "Invalid time";
    }
    return null;
  }
}
