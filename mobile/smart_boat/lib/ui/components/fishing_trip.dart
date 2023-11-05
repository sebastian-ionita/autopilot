import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:print_color/print_color.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/AButton.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/utils/utils.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import 'package:smart_boat/ui/new_base/ASelectableButton.dart';
import 'package:smart_boat/utils.dart';
import '../base/ABottomSheet.dart';
import '../base/AConfirmation.dart';
import '../base/ATextField/ATextField.dart';
import '../base/theme.dart';
import '../models/fishing_trip.dart';
import '../models/map_point.dart';
import '../models/routine.dart';

class FishingTripWidget extends StatefulWidget {
  BuildContext parentContext;
  FishingTrip? fishingTrip;
  FishingTripWidget(
      {Key? key, required this.parentContext, required this.fishingTrip})
      : super(key: key);

  @override
  _FishingTripWidgetState createState() => _FishingTripWidgetState();
}

class _FishingTripWidgetState extends State<FishingTripWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController nameController;
  late TabController tabController;
  late Point home;
  late List<Point> rodPoints = [];

  @override
  void initState() {
    super.initState();
    if (widget.fishingTrip != null) {
      nameController = TextEditingController(text: widget.fishingTrip!.name);
      home = widget.fishingTrip!.home!;
      rodPoints = widget.fishingTrip!.rodPoints;
    } else {
      nameController = TextEditingController();
      //initialize home and rod points
      home = Point(color: Colors.white, index: 0, name: "Home", location: null);
      rodPoints.add(Point(
          color: Colors.blue,
          index: 1,
          name: "Rod 1",
          location: null)); // rod 1
      rodPoints.add(Point(
          color: Colors.green,
          index: 2,
          name: "Rod 2",
          location: null)); // rod 1
      rodPoints.add(Point(
          color: Colors.red, index: 3, name: "Rod 3", location: null)); // rod 1
      rodPoints.add(Point(
          color: Colors.purple,
          index: 4,
          name: "Rod 4",
          location: null)); // rod 1
    }
    tabController = TabController(
        vsync: this, length: 1); // Change length as per your requirement
  }

  @override
  void dispose() {
    nameController.dispose();
    tabController.dispose();
    super.dispose();
  }

  void saveFishingTrip(AppState appState) {
    if (widget.fishingTrip == null) {
      //add new fishing tri[]
      var trip = FishingTrip(
          name: nameController.text,
          home: home,
          rodPoints: rodPoints,
          mapPosition: null,
          routine: Routine(running: false, steps: [], id: NumberUtils.rndId(6)),
          createdOn: DateTime.now().toLocal());
      appState.addFishingTrip(trip);
    } else {
      widget.fishingTrip!.name = nameController.text;
      widget.fishingTrip!.home = home;
      widget.fishingTrip!.rodPoints = rodPoints;
      /* if (widget.state.updateState != null) {
        widget.state.updateState!();
      } */
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, appState, __) {
      return Column(children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 10),
          child: AText(
            text: "Add a Fishing Trip",
            type: ATextTypes.smallHeading,
            color: SmartBoatTheme.of(context).primaryTextColor,
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10),
          child: AText(
            textAlign: TextAlign.center,
            text:
                "Define a name for your fishing trip, you can set current boat location as 'Home' point",
            type: ATextTypes.normal,
            color: SmartBoatTheme.of(context).secondaryTextColor,
          ),
        ),
        Expanded(
            child: TabBarView(
          controller: tabController,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ATextField(
                              type: ATextFieldTypes.text,
                              controller: nameController,
                              label: "Trip name",
                              placeholder: 'Add a trip name'),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: AText(
                        type: ATextTypes.small,
                        text: "Home point",
                        color: SmartBoatTheme.of(context).primaryTextColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: AText(
                          type: ATextTypes.small,
                          color: SmartBoatTheme.of(context).secondaryTextColor,
                          text:
                              "Press and confirm to set as current boat location"),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ASelectableButton(
                                buttonText: "Home",
                                selected: home.location != null,
                                onPressed: () async {
                                  if (appState.boatLocation != null) {
                                    if (home.location != null) {
                                      await showModalBottomSheet(
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (context) {
                                            return ABottomSheet(
                                                height: 250,
                                                child: AConfirmation(
                                                    confirm: () async {
                                                      home.location =
                                                          appState.boatLocation;
                                                      appState.refresh();
                                                      Utils.showSnack(
                                                          SnackTypes.Info,
                                                          "Home was set as the current boat location",
                                                          widget.parentContext);
                                                      setState(() {});
                                                    },
                                                    text:
                                                        "Are you sure you want to set home as current boat location? This will override the actual home point."));
                                          });
                                    } else {
                                      home.location = appState.boatLocation;
                                      appState.refresh();
                                      Utils.showSnack(
                                          SnackTypes.Info,
                                          "Home was set as the current boat location",
                                          widget.parentContext);
                                      setState(() {});
                                    }
                                  } else {
                                    Print.red("Here");
                                    Utils.showSnack(
                                        SnackTypes.Error,
                                        "Boat location cannot be retrieved",
                                        widget.parentContext);
                                  }
                                },
                                icon: const Icon(
                                  Icons.home_filled,
                                ),
                                type: ASelectableButtonTypes.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    children: [
                      widget.fishingTrip != null
                          ? AButton(
                              type: AButtonTypes.secondary,
                              buttonText: "Delete",
                              onPressed: () async {
                                HapticFeedback.heavyImpact();

                                await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (context) {
                                      return ABottomSheet(
                                          height: 240,
                                          child: AConfirmation(
                                              confirm: () async {
                                                if (appState
                                                    .selectedFishingTrip!
                                                    .routine!
                                                    .running) {
                                                  Utils.showSnack(
                                                      SnackTypes.Error,
                                                      "You cannot remove this fishing trip because a routine is running.",
                                                      context);
                                                  return;
                                                }
                                                appState.removeFishingTrip(
                                                    widget.fishingTrip!);
                                                Navigator.pop(context);
                                              },
                                              title: "Confirmation",
                                              text:
                                                  "Are you sure you want to remove fihsing trip: '${widget.fishingTrip!.name}'"));
                                    });
                              })
                          : const SizedBox(),
                      AButton(
                          type: AButtonTypes.primary,
                          disabled: nameController.text.isEmpty,
                          buttonText:
                              widget.fishingTrip != null ? "Update" : "Add",
                          onPressed: () async {
                            saveFishingTrip(appState);
                          }),
                    ],
                  ),
                )
              ],
            ),
            /* RoutineConfigWidget()
         */
          ],
        ))
      ]);
    });
  }
}
