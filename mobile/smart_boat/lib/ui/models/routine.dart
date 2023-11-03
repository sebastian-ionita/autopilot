import 'dart:ui';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:print_color/print_color.dart';

import '../../ble/ble_device_interactor.dart';
import '../../services/message_sender.dart';
import '../base/utils/utils.dart';
import 'app_state.dart';

class Routine {
  late bool running;
  late String id;
  late List<RoutineStep> steps;
  Routine({required this.running, required this.id, required this.steps});

  factory Routine.fromJson(Map<String, dynamic> json) {
    var stepsList = json['steps'] as List;
    List<RoutineStep> steps =
        stepsList.map((e) => RoutineStep.fromJson(e)).toList();
    return Routine(id: json['id'], running: json['running'], steps: steps);
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> stepsJson =
        steps.map((step) => step.toJson()).toList();
    return {'id': id, 'running': running, 'steps': stepsJson};
  }

  Future<void> sendRoutine(AppState state, BleDeviceInteractor deviceInteractor,
      ConnectionStateUpdate connectionState) async {
    var messageSender = MessageSenderService(
        appState: state,
        deviceInteractor: deviceInteractor,
        connectionState: connectionState);
    await messageSender.initializeSendCharacteristic();

    var stepsToSend = state.selectedFishingTrip!.routine!.steps
        .where((s) => s.stored == false)
        .toList();
    for (int i = 0; i < stepsToSend.length; i++) {
      var wayPointMessage =
          "WP:${stepsToSend[i].point!.latitude.toStringAsFixed(6)}@,${stepsToSend[i].point!.longitude.toStringAsFixed(6)}||${stepsToSend[i].unloadLeft ? "1" : "0"}@,${stepsToSend[i].unloadRight ? "1" : "0"}##$i-*";
      Print.magenta(wayPointMessage);

      await messageSender.sendMessage(wayPointMessage);
    }

    await messageSender.sendMessage("GETWP*",
        stopTransmission: false); //send message to validate steps
  }

  Future<void> validateSteps(AppState state,
      BleDeviceInteractor deviceInteractor, String validateMessage) async {
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

      //if all steps stored, send start
      if (!state.selectedFishingTrip!.routine!.steps.any((s) => !s.stored)) {
        /*  var messageSender = MessageSenderService(
            appState: state,
            deviceInteractor: deviceInteractor,
            connectionState: connectionState);
        await messageSender.initializeSendCharacteristic();
        await messageSender.sendMessage("START*",
            stopTransmission: false); //send message to validate steps */
      } else {
        //else send not stored steps
        //sendRoutine(state, deviceInteractor, connectionState)
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
        pointColor: HexColor.fromHex(json['pointColor']),
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
      'pointColor': pointColor!.toHex(),
      'point': point != null ? point!.toJson() : null,
    };
  }
}
