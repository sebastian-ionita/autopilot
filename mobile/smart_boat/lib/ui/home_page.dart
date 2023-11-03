import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:print_color/print_color.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/theme.dart';
import 'package:smart_boat/ui/components/map.dart';
import 'package:smart_boat/ui/components/routine_preview.dart';
import 'package:smart_boat/ui/models/app_state.dart';

import '../services/secure_storage_service.dart';
import 'base/AIconButton.dart';
import 'components/actions_container.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({Key? key}) : super(key: key);

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late SecureStorageService secureStorageService;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConnectionStateUpdate, AppState>(
        builder: (_, bleConnectionStatus, appState, __) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: SmartBoatTheme.of(context).secondaryBackground,
        child: Stack(
          children: [
            MapWidget(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      bleConnectionStatus.connectionState ==
                              DeviceConnectionState.connected
                          ? Align(
                              alignment: Alignment.bottomLeft,
                              child: ActionsContainerWidget())
                          : const SizedBox(),
                      Padding(
                        padding: EdgeInsets.only(
                            right: 10,
                            top: 15,
                            bottom: (bleConnectionStatus.connectionState !=
                                    DeviceConnectionState.connected
                                ? 10
                                : 0)),
                        child: AIconButton(
                          borderRadius: 30,
                          icon: const Icon(Icons.my_location_rounded),
                          onPressed: () async {
                            Location location = Location();

                            LocationData? locationData;
                            try {
                              locationData = await location.getLocation();
                            } on Exception {
                              Print.red("Couldn't get location details");
                            }
                            if (locationData != null) {
                              appState.mapController
                                  .animateCamera(CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  bearing: 0,
                                  target: LatLng(locationData.latitude!,
                                      locationData.longitude!),
                                  zoom: 17.0,
                                ),
                              ));
                            }
                          },
                        ),
                      )
                    ],
                  ),
                  appState.fishingTrips.isNotEmpty &&
                          bleConnectionStatus.connectionState ==
                              DeviceConnectionState.connected &&
                          appState.selectedFishingTrip != null
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: RoutinePreviewWidget(),
                        )
                      : const SizedBox()
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
