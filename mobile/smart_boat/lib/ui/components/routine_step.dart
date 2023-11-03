import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/ADropdown/ADropdown.dart';
import 'package:smart_boat/ui/base/AIconButton.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/models/routine.dart';
import 'package:smart_boat/ui/new_base/ASelectableButton.dart';

import '../base/theme.dart';
import '../models/app_state.dart';

typedef void IntCallback(int value);

// ignore: must_be_immutable
class RoutineStepWidget extends StatefulWidget {
  final int index;
  RoutineStep step;
  final Function(int index)? removeCallback;
  RoutineStepWidget(
      {Key? key,
      required this.index,
      required this.step,
      required this.removeCallback})
      : super(key: key);

  @override
  _RoutineStepWidgetState createState() => _RoutineStepWidgetState();
}

class _RoutineStepWidgetState extends State<RoutineStepWidget> {
  @override
  void initState() {
    super.initState();
  }

  List<AOption<int>> getPointOptions(AppState state) {
    List<AOption<int>> options = [];
    for (var rp in state.selectedFishingTrip!.rodPoints) {
      if (rp.location != null) {
        options.add(AOption<int>(value: rp.index, label: rp.name));
      }
    }
    if (state.selectedFishingTrip!.home!.location != null) {
      options.add(AOption(value: -1, label: "Home"));
    }
    return options;
  }

  void setStepBasedOnSelectedItem(AppState state, AOption<int> selectedPoint) {
    //selected point is between rods
    if (state.selectedFishingTrip!.rodPoints
        .any((element) => element.index == selectedPoint.value)) {
      //set rod point
      var rodPoint = state.selectedFishingTrip!.rodPoints
          .firstWhere((element) => element.index == selectedPoint.value);
      widget.step.name = rodPoint.name;
      widget.step.point = rodPoint.location;
      widget.step.pointColor = rodPoint.color;

      state.saveState();
      state.refresh();
      return;
    }
    if (selectedPoint.value == -1) {
      widget.step.name = state.selectedFishingTrip!.home!.name;
      widget.step.point = state.selectedFishingTrip!.home!.location;
      state.saveState();
      state.refresh();
      return;
    }
    //maybe selected point is home
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, appState, __) {
      return Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 10),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: widget.step.pointColor,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(
                  width: 60,
                  child: AText(
                      type: ATextTypes.small,
                      color: SmartBoatTheme.of(context).primaryTextColor,
                      text: widget.step.name.toUpperCase())),
              Container(
                width: 70,
                padding: const EdgeInsets.only(right: 5),
                child: ASelectableButton(
                    type: ASelectableButtonTypes.primarySmall,
                    selected: widget.step.unloadLeft,
                    buttonText: "Left",
                    onPressed: () async {
                      setState(() {
                        widget.step.unloadLeft = !widget.step.unloadLeft;
                      });
                      appState.saveState();
                      appState.refresh();
                    }),
              ),
              Container(
                width: 70,
                padding: const EdgeInsets.only(right: 5),
                child: ASelectableButton(
                    type: ASelectableButtonTypes.primarySmall,
                    selected: widget.step.unloadRight,
                    buttonText: "Right",
                    onPressed: () async {
                      setState(() {
                        widget.step.unloadRight = !widget.step.unloadRight;
                      });
                      appState.saveState();
                      appState.refresh();
                    }),
              ),
              Container(
                width: 70,
                padding: const EdgeInsets.only(right: 5),
                child: ASelectableButton(
                    type: ASelectableButtonTypes.primarySmall,
                    selected: false,
                    buttonText: "Both",
                    onPressed: () async {}),
              )
            ],
          ));
    });
  }
}
