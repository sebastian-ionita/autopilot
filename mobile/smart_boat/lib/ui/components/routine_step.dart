import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/ADropdown/ADropdown.dart';
import 'package:smart_boat/ui/base/AIconButton.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/models/routine.dart';

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
          decoration: BoxDecoration(
              border: Border.all(
                color: widget.step.stored
                    ? SmartBoatTheme.of(context).primaryButtonColor
                    : Colors.transparent,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Colors.grey),
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.all(5),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SizedBox(
                    width: 100,
                    child:
                        AText(type: ATextTypes.small, text: widget.step.name)),
                SizedBox(
                  width: 170,
                  child: ADropdown<int>(
                      options: getPointOptions(appState),
                      hintText: "Select..",
                      initialOption: null,
                      onChanged: (item) {
                        if (item != null) {
                          setStepBasedOnSelectedItem(appState, item);
                          //update step point and name with the values from selected in the ddl
                        }
                      }),
                ),
                AIconButton(
                  borderColor: Colors.green,
                  borderRadius: 10,
                  fillColor: SmartBoatTheme.of(context).primaryBackground,
                  borderWidth: 1,
                  icon: Icon(
                    Icons.remove,
                    color: SmartBoatTheme.of(context).primaryText,
                    size: 20,
                  ),
                  onPressed: () async {
                    if (widget.removeCallback != null) {
                      widget.removeCallback!(widget.index);
                    }
                  },
                )
              ]),
              Row(children: [
                AText(type: ATextTypes.small, text: "Left"),
                Checkbox(
                  checkColor: Colors.white,
                  value: widget.step.unloadLeft,
                  onChanged: (bool? value) {
                    setState(() {
                      widget.step.unloadLeft = value!;
                    });
                    appState.saveState();
                    appState.refresh();
                  },
                ),
                AText(type: ATextTypes.small, text: "Right"),
                Checkbox(
                  checkColor: Colors.white,
                  value: widget.step.unloadRight,
                  onChanged: (bool? value) {
                    setState(() {
                      widget.step.unloadRight = value!;
                    });
                    appState.saveState();
                    appState.refresh();
                  },
                ),
              ]),
            ],
          ));
    });
  }
}
