import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import '../models/map_point.dart';

class LiveDataWidget extends StatefulWidget {
  LiveDataWidget({Key? key}) : super(key: key);

  @override
  _LiveDataWidgetState createState() => _LiveDataWidgetState();
}

class _LiveDataWidgetState extends State<LiveDataWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController nameController;
  late TabController tabController;
  late Point home;
  late List<Point> rodPoints = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, appState, __) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AText(type: ATextTypes.heading, text: "Live data"),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AText(type: ATextTypes.normal, text: "Location: "),
              appState.boatLocation != null
                  ? AText(
                      type: ATextTypes.normal,
                      text:
                          "LAT: ${appState.boatLocation!.latitude.toString()} LNG: ${appState.boatLocation!.longitude.toString()}")
                  : const SizedBox(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AText(type: ATextTypes.normal, text: "Point distance: "),
              appState.boatLocation != null
                  ? AText(
                      type: ATextTypes.normal,
                      text: appState.boatLiveData!.distance)
                  : const SizedBox(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AText(type: ATextTypes.normal, text: "Heading: "),
              appState.boatLocation != null
                  ? AText(
                      type: ATextTypes.normal,
                      text: appState.boatLiveData!.heading)
                  : const SizedBox(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AText(type: ATextTypes.normal, text: "Relative bearing: "),
              appState.boatLocation != null
                  ? AText(
                      type: ATextTypes.normal,
                      text: appState.boatLiveData!.relativeBearing)
                  : const SizedBox(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AText(type: ATextTypes.normal, text: "Rudder position: "),
              appState.boatLocation != null
                  ? AText(
                      type: ATextTypes.normal,
                      text: appState.boatLiveData!.rudderPosition)
                  : const SizedBox(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              AText(type: ATextTypes.normal, text: "Main motor speed: "),
              appState.boatLocation != null
                  ? AText(
                      type: ATextTypes.normal,
                      text: appState.boatLiveData!.motorSpeed)
                  : const SizedBox(),
            ],
          ),
        ),
      ]);
    });
  }
}
