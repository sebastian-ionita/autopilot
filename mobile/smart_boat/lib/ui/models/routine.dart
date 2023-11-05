import 'dart:ui';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:print_color/print_color.dart';
import '../../locator.dart';
import '../../services/message_sender.dart';
import '../base/utils/utils.dart';
import 'app_state.dart';

class Routine {
  late bool running;
  late String id;
  late List<RoutineStep> steps;
  List<LatLng> routinePath = [];

  Routine({required this.running, required this.id, required this.steps});

  factory Routine.fromJson(Map<String, dynamic> json) {
    var stepsList = json['steps'] as List;
    List<RoutineStep> steps =
        stepsList.map((e) => RoutineStep.fromJson(e)).toList();
    return Routine(
        id: json['id'] != null ? json['id'] : '',
        running: json['running'],
        steps: steps);
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> stepsJson =
        steps.map((step) => step.toJson()).toList();
    return {'id': id, 'running': running, 'steps': stepsJson};
  }

  void clearProgress() {
    running = false;
    routinePath = [];
    for (var step in steps) {
      step.reached = false;
      step.running = false;
    }
  }

  Future<void> sendRoutine() async {
    var messageSender = locator<MessageSenderService>();
    //await messageSender.initializeSendCharacteristic();
    Print.red("Sending routine with id: $id");

    //clean routine and routine steps flags
    clearProgress();

    var stepsToSend = steps.where((s) => s.stored == false).toList();
    for (int i = 0; i < stepsToSend.length; i++) {
      var wayPointMessage =
          "WP:${stepsToSend[i].point!.latitude.toStringAsFixed(6)}@,${stepsToSend[i].point!.longitude.toStringAsFixed(6)}||${stepsToSend[i].unloadLeft ? "1" : "0"}@,${stepsToSend[i].unloadRight ? "1" : "0"}##$i-*";
      Print.magenta(wayPointMessage);

      await messageSender.sendMessage(wayPointMessage);
    }

    await messageSender.sendMessage("GETWP*"); //send message to validate steps

    //await messageSender.sendMessage("START*", stopTransmission: false);
    await messageSender.sendMessage("START:$id*"); //send routine with id
  }

  Future<void> validateSteps(AppState state, String validateMessage) async {
    var stepsValidationMessages = validateMessage.split("@");
    if (stepsValidationMessages.isNotEmpty) {
      for (var stepResultMessage in stepsValidationMessages) {
        try {
          var items = stepResultMessage.split("|");
          if (items.isNotEmpty) {
            var index = int.tryParse(items[0]); //this is the index of the step
            if (index != null) {
              state.selectedFishingTrip!.routine!.steps[index].stored = true;
            }
          }
        } catch (e) {
          //error on parsing the step messages
          Print.red(
              "Error on parsing the step validation message: $stepResultMessage");
        }
      }

      if (!state.selectedFishingTrip!.routine!.steps.any((s) => !s.stored)) {
        //if all steps stored, send start
        Print.yellow("All points stored, send START command");
        var messageSender = locator<MessageSenderService>();
        //await messageSender.initializeSendCharacteristic();
        await messageSender.sendMessage("START*",
            stopTransmission: false); //send message to validate steps
      } else {
        //else send not stored steps
        Print.yellow("Not all points stored, send remaining ones.");
        sendRoutine();
      }

      state.saveState();
      state.refresh();
    }
  }
}

class RoutineStep {
  late int? index;
  late String name;
  late bool unloadLeft;
  late bool unloadRight;
  late LatLng? point;
  late Color? pointColor;
  bool stored;

  bool running = false;
  bool reached = false;

  RoutineStep(
      {required this.index,
      required this.name,
      required this.unloadLeft,
      required this.unloadRight,
      required this.pointColor,
      required this.stored,
      required this.point});

  factory RoutineStep.fromJson(Map<String, dynamic> json) {
    return RoutineStep(
        pointColor: json['pointColor'] != null
            ? HexColor.fromHex(json['pointColor'])
            : null,
        index: json['index'],
        name: json['name'] ?? '',
        unloadLeft: json['unloadLeft'],
        unloadRight: json['unloadRight'],
        stored: json["stored"] != null ? json["stored"].toBool() : false,
        point: json["point"] != null ? LatLng.fromJson(json['point']) : null);
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'name': name,
      'unloadLeft': unloadLeft,
      'unloadRight': unloadRight,
      'pointColor': pointColor != null ? pointColor!.toHex() : null,
      'point': point != null ? point!.toJson() : null,
    };
  }
}
