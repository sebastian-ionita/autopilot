import 'package:google_maps_flutter/google_maps_flutter.dart';

class Routine {
  late bool running;
  late List<RoutineStep> steps;
  Routine({required this.running, required this.steps});

  factory Routine.fromJson(Map<String, dynamic> json) {
    var stepsList = json['steps'] as List;
    List<RoutineStep> steps =
        stepsList.map((e) => RoutineStep.fromJson(e)).toList();
    return Routine(running: json['running'], steps: steps);
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> stepsJson =
        steps.map((step) => step.toJson()).toList();
    return {'running': running, 'steps': stepsJson};
  }
}

class RoutineStep {
  late int? index;
  late String name;
  late bool unloadLeft;
  late bool unloadRight;
  late LatLng? point;

  RoutineStep(
      {required this.index,
      required this.name,
      required this.unloadLeft,
      required this.unloadRight,
      required this.point});

  factory RoutineStep.fromJson(Map<String, dynamic> json) {
    return RoutineStep(
        index: json['index'],
        name: json['name'] ?? '',
        unloadLeft: json['unloadLeft'],
        unloadRight: json['unloadRight'],
        point:
            json["point"] != null ? LatLng.fromJson(json['location']) : null);
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'name': name,
      'unloadLeft': unloadLeft,
      'unloadRight': unloadRight,
      'point': point != null ? point!.toJson() : null,
    };
  }
}
