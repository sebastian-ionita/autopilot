// ignore: avoid_print
import 'dart:math';

import 'package:flutter/cupertino.dart';

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
