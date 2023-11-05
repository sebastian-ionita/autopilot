import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/AIconButton.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/theme.dart';
import 'package:smart_boat/ui/base/utils/utils.dart';
import 'package:smart_boat/ui/components/routine_config.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import 'package:smart_boat/ui/models/routine.dart';
import '../base/ABottomSheet.dart';
import '../base/AConfirmation.dart';

class RoutinePreviewWidget extends StatefulWidget {
  RoutinePreviewWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RoutinePreviewWidgetState createState() => _RoutinePreviewWidgetState();
}

class _RoutinePreviewWidgetState extends State<RoutinePreviewWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  Routine getRoutine(AppState appState) {
    return appState.selectedFishingTrip!.routine!;
  }

  Widget routinePreview(AppState appState) {
    var routine = getRoutine(appState);
    List<Widget> routinePoints = [];
    var steps = routine.steps;
    if (steps.isNotEmpty) {
      for (var i = 0; i < steps.length; i++) {
        var step = steps[i];
        if (step.point != null) {
          if (step.name != "Home") {
            routinePoints.add(Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 5),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: step.pointColor,
                    borderRadius: BorderRadius.circular(10)),
              ),
            ));
          }

          routinePoints.add(Container(
            decoration: BoxDecoration(
                border: Border(
              bottom: BorderSide(
                  width: 1,
                  color: (step.reached
                      ? Colors.green
                      : (step.running
                          ? Colors.blue
                          : SmartBoatTheme.of(context).primaryBackground))),
            )),
            padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
            child: AText(
              type: ATextTypes.small,
              text:
                  "${step.name} ${step.unloadLeft ? "(L)" : (step.unloadRight ? "(R)" : '')}",
              color: SmartBoatTheme.of(context).primaryTextColor,
            ),
          ));
          if (i < steps.length - 1) {
            routinePoints.add(separator());
          }
        }
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (appState.selectedFishingTrip!.rodPoints
                  .any((r) => r.location != null)) {
                if (appState.selectedFishingTrip!.routine!.running) {
                  Utils.showSnack(SnackTypes.Info,
                      "When running, routine cannot be updated!", context);
                  return;
                }
                showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (bottomSheetContext) {
                      return ABottomSheet(
                          height: 700, child: RoutineConfigWidget());
                    });
              } else {
                Utils.showSnack(
                    SnackTypes.Info, "Please add points on the map", context);
                return;
              }
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(width: 1, color: Colors.green)),
                    ),
                    padding:
                        const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                    child: AText(
                        type: ATextTypes.small,
                        text: "Home",
                        color: SmartBoatTheme.of(context).primaryTextColor),
                  ),
                  separator(),
                  ...routinePoints
                ],
              ),
            ),
          ),
        ),
        Container(
          height: 30,
          width: 1,
          color: SmartBoatTheme.of(context).dividerColor,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: appState.selectedFishingTrip!.routine!.running
              ? AIconButton(
                  fillColor:
                      SmartBoatTheme.of(context).primaryButtonDisabledColor,
                  borderRadius: 30,
                  icon: const Icon(Icons.stop),
                  onPressed: () async {
                    await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return ABottomSheet(
                              height: 250,
                              child: AConfirmation(
                                  confirm: () async {
                                    //todo: send stop command to the boat
                                    Utils.showSnack(SnackTypes.Info,
                                        "Boat will return home", context);
                                  },
                                  title: "Stop execution",
                                  text:
                                      "This will stop what the boat is doing and it will return home. Are you sure you want this?"));
                        });
                  },
                )
              : AIconButton(
                  fillColor:
                      SmartBoatTheme.of(context).primaryButtonDisabledColor,
                  borderRadius: 30,
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () async {
                    await sendRoutine(appState);
                  },
                ),
        )
      ],
    );
  }

  Widget separator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: AText(
          type: ATextTypes.normal,
          text: ">>",
          fontWeight: FontWeight.bold,
          color: SmartBoatTheme.of(context).selectedTextColor),
    );
  }

  Future<void> sendRoutine(AppState state) async {
    if (state.selectedFishingTrip!.routine != null) {
      //set points stored flag to false
      for (var element in state.selectedFishingTrip!.routine!.steps) {
        element.stored = false;
      }
      state.saveState();
      state.refresh();
      //send new routine
      await state.selectedFishingTrip!.routine!.sendRoutine();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, appState, __) {
      return Container(
        width: double.infinity,
        height: 60,
        padding: const EdgeInsets.only(right: 10, left: 5),
        decoration:
            BoxDecoration(color: SmartBoatTheme.of(context).primaryBackground),
        child: getRoutine(appState).steps.isEmpty
            ? GestureDetector(
                onTap: () {
                  if (appState.selectedFishingTrip!.rodPoints
                      .any((r) => r.location != null)) {
                    if (appState.selectedFishingTrip!.routine!.running) {
                      Utils.showSnack(SnackTypes.Info,
                          "When running, routine cannot be updated!", context);
                      return;
                    }
                    showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (bottomSheetContext) {
                          return ABottomSheet(
                              height: 700, child: RoutineConfigWidget());
                        });
                  } else {
                    Utils.showSnack(SnackTypes.Info,
                        "Please add points on the map", context);
                    return;
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: AText(
                        type: ATextTypes.normal,
                        textAlign: TextAlign.center,
                        color: SmartBoatTheme.of(context).primaryTextColor,
                        text: "Set Routine"),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 10),
                child: routinePreview(appState),
              ),
      );
    });
  }
}
