import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_boat/ui/base/AButton.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import 'package:smart_boat/ui/new_base/ASelectableButton.dart';
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
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: AText(
                type: ATextTypes.normal,
                color: SmartBoatTheme.of(context).primaryTextColor,
                text: "No rod points defined for this fishing trip"),
          ),
        )
      ];
    }
    return widget.state.selectedFishingTrip!.rodPoints
        .map((point) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ASelectableButton(
                  type: ASelectableButtonTypes.primary,
                  icon: Icon(
                    Icons.circle,
                    color: point.color,
                    size: 20,
                  ),
                  selected: point.location != null,
                  buttonText: "Set as point ${point.index}",
                  onPressed: () async {
                    point.location = widget.location;
                    widget.state.refresh();
                    Navigator.pop(context);
                  }),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 10),
          child: AText(
            text:
                "Configuration for: ${widget.state.selectedFishingTrip!.name}",
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
                "Clicked location details: Lat: ${widget.location.latitude} Lng: ${widget.location.longitude}",
            type: ATextTypes.normal,
            color: SmartBoatTheme.of(context).secondaryTextColor,
          ),
        ),
        Column(
          children: [
            ASelectableButton(
                type: ASelectableButtonTypes.primary,
                selected:
                    widget.state.selectedFishingTrip!.home!.location != null,
                buttonText: "Set as Home point",
                onPressed: () async {
                  widget.state.selectedFishingTrip!.home = Point(
                      color: Colors.white,
                      index: 0,
                      name: "Home",
                      location: widget.location);
                  widget.state.refresh();
                  Navigator.pop(context);
                }),
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
