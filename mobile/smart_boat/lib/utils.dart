// ignore: avoid_print
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
