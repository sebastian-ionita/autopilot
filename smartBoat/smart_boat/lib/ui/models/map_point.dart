import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../base/utils/utils.dart';

class Point {
  Point(
      {required this.color,
      required this.index,
      required this.name,
      required this.location});
  late Color color;
  late String name;
  late int index;

  late LatLng? location;

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
        color: HexColor.fromHex(json['color']),
        index: json['index'],
        name: json['name'],
        location: json["location"] != null
            ? LatLng.fromJson(json['location'])
            : null);
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color.toHex(),
      'index': index,
      'name': name,
      'location': location != null ? location!.toJson() : null
    };
  }
}
