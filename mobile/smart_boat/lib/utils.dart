// ignore: avoid_print
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void log(String text) => print("[FlutterReactiveBLEApp] $text");

Future<T?> pushRoute<T extends Object?>(
    BuildContext context, Route<T> route) async {
  //check connectivity on redirect
  return Navigator.push<T>(
    context,
    route,
  );
}

class NumberUtils {
  static String rndId(int length) {
    const String allowedCharacters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();
    String id = '';

    for (int i = 0; i < length; i++) {
      final int randomIndex = random.nextInt(allowedCharacters.length);
      id += allowedCharacters[randomIndex];
    }

    return id;
  }
}

class LocationUtils {
  static bool arePointsInRadius(LatLng point1, LatLng point2, double radius) {
    double distance = calculateDistance(point1, point2);
    return distance <= radius;
  }

  static double calculateDistance(LatLng point1, LatLng point2) {
    const earthRadius = 6371000.0; // Earth's radius in meters

    double dLat = _degreesToRadians(point2.latitude - point1.latitude);
    double dLon = _degreesToRadians(point2.longitude - point1.longitude);

    double a = pow(sin(dLat / 2), 2) +
        cos(_degreesToRadians(point1.latitude)) *
            cos(_degreesToRadians(point2.latitude)) *
            pow(sin(dLon / 2), 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }
}
