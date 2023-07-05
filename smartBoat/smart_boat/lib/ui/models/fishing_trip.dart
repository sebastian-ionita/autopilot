import 'package:smart_boat/ui/models/trip_camera_position.dart';

import 'map_point.dart';

class FishingTrip {
  FishingTrip(
      {required this.name,
      required this.home,
      required this.rodPoints,
      required this.mapPosition,
      required this.createdOn});

  late String name;
  late Point? home;
  late List<Point> rodPoints;
  late DateTime createdOn;
  late TripCameraPosition? mapPosition;

  // Convert a JSON object into a FishingTrip object.
  factory FishingTrip.fromJson(Map<String, dynamic> json) {
    var rodPointsList = json['rodPoints'] as List;
    List<Point> rodPoints =
        rodPointsList.map((e) => Point.fromJson(e)).toList();

    return FishingTrip(
        name: json['name'],
        mapPosition: json["mapPosition"] != null
            ? TripCameraPosition.fromJson(json["mapPosition"])
            : null,
        createdOn: DateTime.parse(json['createdOn']),
        home: json['home'] != null ? Point.fromJson(json['home']) : null,
        rodPoints: rodPoints);
  }

  // Convert this FishingTrip object into a JSON object.
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> rodPointsJson =
        rodPoints.map((point) => point.toJson()).toList();

    return {
      'name': name,
      'mapPosition': mapPosition != null ? mapPosition!.toJson() : null,
      'home': home != null ? home!.toJson() : null,
      'rodPoints': rodPointsJson,
      'createdOn': createdOn.toIso8601String()
    };
  }
}
