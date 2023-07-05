class TripCameraPosition {
  TripCameraPosition(
      {required this.targetLat,
      required this.targetLng,
      required this.zoom,
      required this.rotation});
  late double targetLat;
  late double targetLng;
  late double zoom;
  late double rotation;

  factory TripCameraPosition.fromJson(Map<String, dynamic> json) {
    return TripCameraPosition(
        targetLat: json['targetLat'],
        targetLng: json['targetLng'],
        zoom: json['zoom'],
        rotation: json["rotation"]);
  }

  Map<String, dynamic> toJson() {
    return {
      'targetLat': targetLat,
      'targetLng': targetLng,
      'zoom': zoom,
      'rotation': rotation
    };
  }
}
