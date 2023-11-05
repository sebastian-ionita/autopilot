import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:print_color/print_color.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ble/ble_device_interactor.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/utils/utils.dart';
import 'package:smart_boat/ui/components/routine_points_board.dart';
import 'package:smart_boat/ui/components/routine_step.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import 'package:smart_boat/ui/models/fishing_trip.dart';
import 'package:smart_boat/ui/models/map_point.dart';
import 'package:smart_boat/ui/models/routine.dart';
import 'package:smart_boat/ui/new_base/ASelectableButton.dart';

import '../base/AButton.dart';
import '../base/theme.dart';

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
    return [
      Container(
        padding: const EdgeInsets.only(top: 30),
        child: Center(
          child: AText(
            text: "No steps defined.",
            type: ATextTypes.normal,
            color: SmartBoatTheme.of(context).primaryTextColor,
          ),
        ),
      )
    ];
  }

  Future<void> clearRoutine(AppState state) async {
    state.selectedFishingTrip!.routine = Routine(
        running: false, steps: [], id: state.selectedFishingTrip!.routine!.id);
    Utils.showSnack(SnackTypes.Info, "Routine was cleared.", context);
    state.saveState();
    state.refresh();
  }

  Future<void> addStep(AppState state, Point selectedPoint) async {
    var nrOfSteps = state.selectedFishingTrip!.routine!.steps.length;
    state.selectedFishingTrip!.routine!.steps.add(RoutineStep(
        index: null,
        name: selectedPoint.name,
        unloadLeft: nrOfSteps == 0 ? true : false,
        pointColor: selectedPoint.color,
        stored: false,
        unloadRight: nrOfSteps == 1 ? true : false,
        point: selectedPoint.location));

    state.saveState();
    state.refresh();
    Utils.showSnack(SnackTypes.Info,
        "${selectedPoint.name} was added to the routine", context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AppState, BleDeviceInteractor, ConnectionStateUpdate>(
        builder: (_, appState, deviceInteractor, connectionStatus, __) {
      return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 10),
          child: AText(
            text: "Configure routine",
            type: ATextTypes.smallHeading,
            textAlign: TextAlign.center,
            color: SmartBoatTheme.of(context).primaryTextColor,
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10),
          child: AText(
            textAlign: TextAlign.center,
            text:
                "Select the points in the desired order to define the routine",
            type: ATextTypes.normal,
            color: SmartBoatTheme.of(context).secondaryTextColor,
          ),
        ),
        appState.selectedFishingTrip?.routine != null
            ? Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20, top: 10),
                        child:
                            RoutinePointsBoardWidget(onSelect: (point) async {
                          await addStep(appState, point);
                        }),
                      ),
                      ...getRoutineSteps(
                          appState, appState.selectedFishingTrip!),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              AButton(
                  type: AButtonTypes.primary,
                  buttonText: "Save",
                  onPressed: () async {
                    Navigator.pop(context);
                  }),
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: ASelectableButton(
                    type: ASelectableButtonTypes.primary,
                    icon: const Icon(Icons.refresh),
                    selected: false,
                    buttonText: "Clear",
                    onPressed: () async {
                      await clearRoutine(appState);
                    }),
              )
            ],
          ),
        )
      ]);
    });
  }
}
