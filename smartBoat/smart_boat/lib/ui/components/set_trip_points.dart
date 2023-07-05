import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_boat/ui/base/AButton.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/utils/controls_utils.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import '../base/AIconButton.dart';
import '../base/theme.dart';
import '../models/map_point.dart';

// ignore: must_be_immutable
class SetTripPointsWidget extends StatefulWidget {
  AppState state;
  LatLng location;
  SetTripPointsWidget({Key? key, required this.state, required this.location})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SetTripPointsWidgetState createState() => _SetTripPointsWidgetState();
}

class _SetTripPointsWidgetState extends State<SetTripPointsWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  List<Widget> getRodButtons() {
    if (widget.state.selectedFishingTrip!.rodPoints.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: AText(
              type: ATextTypes.small,
              text: "No rod points defined for this fishing trip"),
        )
      ];
    }
    return widget.state.selectedFishingTrip!.rodPoints
        .map((point) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: AIconButton(
                borderColor: SmartBoatTheme.of(context).primaryBackground,
                borderRadius: 10,
                fillColor: SmartBoatTheme.of(context).primaryBackground,
                borderWidth: 1,
                text: "Set as rod point ${point.index}",
                icon: Icon(
                  Icons.circle,
                  color: point.color,
                  size: 20,
                ),
                onPressed: () async {
                  point.location = widget.location;
                  widget.state.refresh();
                  Navigator.pop(context);
                },
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: AText(
                            type: ATextTypes.normal,
                            text: widget.state.selectedFishingTrip!.name
                                .capitalize()),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.map),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 20, left: 20),
                        child: AText(
                            type: ATextTypes.small,
                            text:
                                "Clicked location details: Lat: ${widget.location.latitude} Lng: ${widget.location.longitude}"),
                      ),
                    ),
                  ],
                ),
                AIconButton(
                  borderColor: SmartBoatTheme.of(context).primaryBackground,
                  borderRadius: 10,
                  fillColor: SmartBoatTheme.of(context).primaryBackground,
                  borderWidth: 1,
                  text: "Set as home point",
                  icon: Icon(
                    Icons.home,
                    color: SmartBoatTheme.of(context).primaryText,
                    size: 20,
                  ),
                  onPressed: () async {
                    widget.state.selectedFishingTrip!.home = Point(
                        color: Colors.white,
                        index: 0,
                        name: "Home",
                        location: widget.location);
                    widget.state.refresh();
                    Navigator.pop(context);
                  },
                ),
                ...getRodButtons(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  AButton(
                      type: AButtonTypes.secondary,
                      buttonText: "Close",
                      onPressed: () async {
                        Navigator.pop(context);
                      })
                ],
              ),
            )
          ]),
    );
  }
}
