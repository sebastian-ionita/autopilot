import 'package:flutter/material.dart';
import 'package:smart_boat/ui/base/AButton.dart';
import 'package:smart_boat/ui/base/AIconButton.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/utils/utils.dart';
import 'package:smart_boat/ui/components/routine_config.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import '../base/ABottomSheet.dart';
import '../base/AConfirmation.dart';
import '../base/ATextField/ATextField.dart';
import '../base/theme.dart';
import '../models/fishing_trip.dart';
import '../models/map_point.dart';
import 'map_preview.dart';

class FishingTripWidget extends StatefulWidget {
  FishingTrip? fishingTrip;
  AppState state;
  FishingTripWidget({Key? key, required this.fishingTrip, required this.state})
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
        vsync: this, length: 2); // Change length as per your requirement
  }

  @override
  void dispose() {
    nameController.dispose();
    tabController.dispose();
    super.dispose();
  }

  void saveFishingTrip() {
    if (widget.fishingTrip == null) {
      //add new fishing tri[]
      var trip = FishingTrip(
          name: nameController.text,
          home: home,
          rodPoints: rodPoints,
          mapPosition: null,
          routine: null,
          createdOn: DateTime.now().toLocal());
      widget.state.addFishingTrip(trip);
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
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.blue,
          ),
          alignment: Alignment.center,
          child: MapPreviewWidget(zoom: 17, center: widget.state.boatLocation),
        ),
      ),
      TabBar(
        labelColor: SmartBoatTheme.of(context).primaryText,
        indicatorColor: SmartBoatTheme.of(context).primaryColor,
        controller: tabController,
        tabs: const [Tab(text: 'Settings'), Tab(text: 'Routine')],
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
                            placeholder: 'Specify location name'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: AText(
                        type: ATextTypes.small,
                        text:
                            "Home point - Press and confirm to set as current boat location"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AIconButton(
                            borderColor: home.location != null
                                ? Colors.green
                                : SmartBoatTheme.of(context).primaryBackground,
                            borderRadius: 10,
                            fillColor:
                                SmartBoatTheme.of(context).primaryBackground,
                            borderWidth: 1,
                            text: "Home",
                            icon: Icon(
                              Icons.home_filled,
                              color: SmartBoatTheme.of(context).primaryText,
                              size: 20,
                            ),
                            onPressed: () async {
                              if (widget.state.boatLocation != null) {
                                if (home.location != null) {
                                  await showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (context) {
                                        return ABottomSheet(
                                            height: 200,
                                            child: AConfirmation(
                                                confirm: () async {
                                                  home.location =
                                                      widget.state.boatLocation;
                                                  widget.state.refresh();
                                                  Utils.showSnack(
                                                      SnackTypes.Info,
                                                      "Home was set as the current boat location",
                                                      context);
                                                  setState(() {});
                                                },
                                                text:
                                                    "Are you sure you want to set home as current boat location? This will override the actual home point."));
                                      });
                                } else {
                                  home.location = widget.state.boatLocation;
                                  widget.state.refresh();
                                  Utils.showSnack(
                                      SnackTypes.Info,
                                      "Home was set as the current boat location",
                                      context);
                                  setState(() {});
                                }
                              } else {
                                Utils.showSnack(
                                    SnackTypes.Error,
                                    "Boat location cannot be retrieved",
                                    context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: AText(
                        type: ATextTypes.small,
                        text:
                            "Rod points - Press and confirm to set as current boat location"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: rodPoints
                            .map(
                              (r) => AIconButton(
                                borderColor: r.location != null
                                    ? Colors.green
                                    : SmartBoatTheme.of(context)
                                        .primaryBackground,
                                borderRadius: 10,
                                fillColor: SmartBoatTheme.of(context)
                                    .primaryBackground,
                                borderWidth: 1,
                                text: r.name,
                                icon: Icon(
                                  Icons.circle,
                                  color: r.color,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  if (widget.state.boatLocation != null) {
                                    if (r.location != null) {
                                      await showModalBottomSheet(
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (context) {
                                            return ABottomSheet(
                                                height: 200,
                                                child: AConfirmation(
                                                    confirm: () async {
                                                      r.location = widget
                                                          .state.boatLocation;
                                                      widget.state.refresh();
                                                      Utils.showSnack(
                                                          SnackTypes.Info,
                                                          "${r.name} was set as the current boat location",
                                                          context);
                                                      setState(() {});
                                                    },
                                                    text:
                                                        "Are you sure you want to set ${r.name} as current boat location? This will override the actual ${r.name} point."));
                                          });
                                    } else {
                                      r.location = widget.state.boatLocation;
                                      widget.state.refresh();
                                      Utils.showSnack(
                                          SnackTypes.Info,
                                          "${r.name} was set as the current boat location",
                                          context);
                                      setState(() {});
                                    }
                                  } else {
                                    Utils.showSnack(
                                        SnackTypes.Error,
                                        "Boat location cannot be retrieved",
                                        context);
                                  }
                                },
                              ),
                            )
                            .toList()),
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
                              await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return ABottomSheet(
                                        height: 200,
                                        child: AConfirmation(
                                            confirm: () async {
                                              widget.state.removeFishingTrip(
                                                  widget.fishingTrip!);
                                              Navigator.pop(context);
                                            },
                                            title: "Confirmation",
                                            text:
                                                "Are you sure you want to remove fhsing trip details for '${widget.fishingTrip!.name}'"));
                                  });
                            })
                        : const SizedBox(),
                    AButton(
                        type: AButtonTypes.primary,
                        buttonText: "Save",
                        onPressed: () async {
                          saveFishingTrip();
                        }),
                  ],
                ),
              )
            ],
          ),
          RoutineConfigWidget()
        ],
      ))
    ]);
  }
}
