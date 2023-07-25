import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:print_color/print_color.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ble/ble_device_interactor.dart';
import 'package:smart_boat/services/message_sender.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/utils/utils.dart';
import 'package:smart_boat/ui/components/routine_step.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import 'package:smart_boat/ui/models/fishing_trip.dart';
import 'package:smart_boat/ui/models/routine.dart';

import '../base/AButton.dart';

// ignore: must_be_immutable
class RoutineConfigWidget extends StatefulWidget {
  RoutineConfigWidget({Key? key}) : super(key: key);

  @override
  _RoutineConfigWidgetState createState() => _RoutineConfigWidgetState();
}

class _RoutineConfigWidgetState extends State<RoutineConfigWidget> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> getRoutineSteps(AppState state, FishingTrip fishingTrip) {
    if (fishingTrip.routine!.steps.isNotEmpty) {
      List<Widget> routineStepsWidgets = [];
      for (int i = 0; i < fishingTrip.routine!.steps.length; i++) {
        routineStepsWidgets.add(RoutineStepWidget(
            index: i,
            step: fishingTrip.routine!.steps[i],
            removeCallback: (int index) {
              Print.red("Remove called for index: $index");
              fishingTrip.routine!.steps.removeAt(index);
              //save and refresh state
              state.saveState();
              state.refresh();
            }));
      }

      return routineStepsWidgets;
    }
    return [];
  }

  Future<void> initializeRoutine(
      AppState state, FishingTrip fishingTrip) async {
    fishingTrip!.routine = Routine(running: false, steps: [
      RoutineStep(
          index: null,
          name: '',
          unloadLeft: false,
          unloadRight: false,
          point: null),
      RoutineStep(
          index: null,
          name: 'Home',
          unloadLeft: false,
          unloadRight: false,
          point: fishingTrip.home!.location),
    ]);

    state.saveState();
    state.refresh();
    Utils.showSnack(
        SnackTypes.Info, "Routine initialized successfully", context);
  }

  Future<void> addStep(AppState state, FishingTrip fishingTrip) async {
    fishingTrip!.routine!.steps.add(RoutineStep(
        index: null,
        name: '',
        unloadLeft: false,
        unloadRight: false,
        point: null));
    state.saveState();
    state.refresh();
    Utils.showSnack(
        SnackTypes.Info, "Step was added, please set point", context);
  }

  Future<void> sendRoutine(AppState state, BleDeviceInteractor deviceInteractor,
      ConnectionStateUpdate connectionState) async {
    var messageSender = MessageSenderService(
        appState: state,
        deviceInteractor: deviceInteractor,
        connectionState: connectionState);
    await messageSender.initializeSendCharacteristic();

    await messageSender.sendMessage("CLEARWP*\n");
    await Future.delayed(const Duration(milliseconds: 20));

    var steps = state.selectedFishingTrip!.routine!.steps;
    for (int i = 0; i < steps.length; i++) {
      var wayPointMessage =
          "WP:${steps[i].point!.latitude.toStringAsFixed(6)}@,${steps[i].point!.longitude.toStringAsFixed(6)}||${steps[i].unloadLeft ? "1" : "0"}@,${steps[i].unloadRight ? "1" : "0"}##$i-*\n";
      Print.magenta(wayPointMessage);

      await messageSender.sendMessage(wayPointMessage);
      await Future.delayed(const Duration(milliseconds: 20));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AppState, BleDeviceInteractor, ConnectionStateUpdate>(
        builder: (_, appState, deviceInteractor, connectionStatus, __) {
      return Container(
        padding: const EdgeInsets.only(bottom: 10, top: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          appState.selectedFishingTrip!.routine == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: AText(
                        type: ATextTypes.normal,
                        text:
                            "No routine defined, start configure one by clicking the 'Add step' button."),
                  ),
                )
              : const SizedBox(),
          appState.selectedFishingTrip?.routine == null
              ? Center(
                  child: Row(
                    children: [
                      AButton(
                          type: AButtonTypes.primary,
                          buttonText: "Start",
                          onPressed: () async {
                            await initializeRoutine(
                                appState, appState.selectedFishingTrip!);
                          }),
                    ],
                  ),
                )
              : const SizedBox(),
          appState.selectedFishingTrip?.routine != null
              ? Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ...getRoutineSteps(
                                  appState, appState.selectedFishingTrip!),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    AButton(
                                        type: AButtonTypes.secondary,
                                        buttonText: "Add step",
                                        onPressed: () async {
                                          await addStep(appState,
                                              appState.selectedFishingTrip!);
                                        }),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: [
                            AButton(
                                type: AButtonTypes.primary,
                                buttonText: "Send routine",
                                onPressed: () async {
                                  //send boat routine
                                  await sendRoutine(appState, deviceInteractor,
                                      connectionStatus);
                                }),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : const SizedBox(),
        ]),
      );
    });
  }
}
