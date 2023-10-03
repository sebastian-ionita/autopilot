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
          stored: false,
          unloadLeft: false,
          unloadRight: false,
          point: null),
      RoutineStep(
          index: null,
          name: 'Home',
          stored: false,
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
        stored: false,
        unloadRight: false,
        point: null));
    state.saveState();
    state.refresh();
    Utils.showSnack(
        SnackTypes.Info, "Step was added, please set point", context);
  }

  Future<void> sendRoutine(AppState state, BleDeviceInteractor deviceInteractor,
      ConnectionStateUpdate connectionState) async {
    if (state.selectedFishingTrip!.routine != null) {
      //set points stored flag to false
      for (var element in state.selectedFishingTrip!.routine!.steps) {
        element.stored = false;
      }
      state.saveState();
      state.refresh();
      //send new routine
      await state.selectedFishingTrip!.routine!
          .sendRoutine(state, deviceInteractor, connectionState);
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
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Row(
                          children: [
                            AButton(
                                type: AButtonTypes.primary,
                                buttonText: "XOFF",
                                onPressed: () async {
                                  var messageSenderService =
                                      MessageSenderService(
                                          appState: appState,
                                          deviceInteractor: deviceInteractor,
                                          connectionState: connectionStatus);

                                  await messageSenderService
                                      .initializeSendCharacteristic();
                                  for (int i = 0; i < 3; i++) {
                                    await messageSenderService
                                        .sendMessage("XOFF*");
                                  }
                                }),
                            const SizedBox(width: 5),
                            AButton(
                                type: AButtonTypes.primary,
                                buttonText: "XON",
                                onPressed: () async {
                                  var messageSenderService =
                                      MessageSenderService(
                                          appState: appState,
                                          deviceInteractor: deviceInteractor,
                                          connectionState: connectionStatus);

                                  await messageSenderService
                                      .initializeSendCharacteristic();
                                  for (int i = 0; i < 3; i++) {
                                    await messageSenderService
                                        .sendMessage("XON*");
                                  }
                                }),
                          ],
                        ),
                      ),
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
                            const SizedBox(width: 5),
                            AButton(
                                type: AButtonTypes.primary,
                                buttonText: "STOP",
                                onPressed: () async {
                                  //send boat routine
                                  var messageSenderService =
                                      MessageSenderService(
                                          appState: appState,
                                          deviceInteractor: deviceInteractor,
                                          connectionState: connectionStatus);

                                  await messageSenderService
                                      .initializeSendCharacteristic();
                                  await messageSenderService
                                      .sendMessage("STOP*");
                                }),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Row(
                          children: [
                            AButton(
                                type: AButtonTypes.primary,
                                buttonText: "Check boat points",
                                onPressed: () async {
                                  var messageSenderService =
                                      MessageSenderService(
                                          appState: appState,
                                          deviceInteractor: deviceInteractor,
                                          connectionState: connectionStatus);

                                  await messageSenderService
                                      .initializeSendCharacteristic();
                                  await messageSenderService.sendMessage(
                                      "GETWP*",
                                      stopTransmission: false);
                                }),
                            const SizedBox(width: 5),
                            AButton(
                                type: AButtonTypes.primary,
                                buttonText: "START",
                                onPressed: () async {
                                  var messageSenderService =
                                      MessageSenderService(
                                          appState: appState,
                                          deviceInteractor: deviceInteractor,
                                          connectionState: connectionStatus);

                                  await messageSenderService
                                      .initializeSendCharacteristic();
                                  await messageSenderService
                                      .sendMessage("START*");
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
        ]),
      );
    });
  }
}
