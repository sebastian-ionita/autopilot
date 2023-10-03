import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:print_color/print_color.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/utils/utils.dart';
import 'package:smart_boat/ui/components/set_trip_points.dart';
import '../../services/marker_conversion.dart';
import '../base/ABottomSheet.dart';
import '../models/app_state.dart';
import '../models/trip_camera_position.dart';

class MapWidget extends StatefulWidget {
  MapWidget({Key? key}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late GoogleMapController mapController;

  late Uint8List? boatIcon = null;
  late Uint8List? rodIcon = null;
  late Uint8List? homeIcon = null;

  void _onMapCreated(GoogleMapController controller, AppState appState) {
    mapController = controller;
    appState.setGoogleMapController(controller);
    //setCameraPosition(appState);
  }

  @override
  void initState() {
    super.initState();

    MarkersWithLabel.getBytesFromCanvasDynamic(
            fontSize: 25,
            iconPath: 'lib/assets/icons/boat_icon.png',
            iconSize: const Size(80, 80),
            plateReg: 'boat')
        .then((icon) {
      setState(() {
        boatIcon = icon;
      });
    });

    MarkersWithLabel.getBytesFromCanvasDynamic(
            fontSize: 25,
            iconPath: 'lib/assets/icons/rod_icon.png',
            iconSize: const Size(80, 80),
            plateReg: 'rod')
        .then((icon) {
      setState(() {
        rodIcon = icon;
      });
    });

    MarkersWithLabel.getBytesFromCanvasDynamic(
            fontSize: 25,
            iconPath: 'lib/assets/icons/home_icon.png',
            iconSize: const Size(80, 80),
            plateReg: 'home')
        .then((icon) {
      setState(() {
        homeIcon = icon;
      });
    });
  }

  LatLng getMapCeter(AppState state) {
    return state.boatLocation != null
        ? state.boatLocation!
        : const LatLng(44.953629, 18.624336);
  }

  Set<Marker> getStateMarkers(AppState state) {
    var markers = <Marker>{};
    if (state.boatLocation != null && boatIcon != null) {
      markers.add(Marker(
          markerId: const MarkerId("boatLocation"),
          position: state.boatLocation!,
          icon: BitmapDescriptor.fromBytes(boatIcon!)));
    }

    if (state.selectedFishingTrip != null) {
      //get fishing trip markers
      if (state.selectedFishingTrip!.home != null &&
          state.selectedFishingTrip!.home!.location != null) {
        markers.add(Marker(
            markerId: const MarkerId('homeCircle'),
            consumeTapEvents: true,
            onTap: () {
              Utils.showSnack(SnackTypes.Info, "Home", context);
            },
            icon: BitmapDescriptor.fromBytes(homeIcon!),
            position: state.selectedFishingTrip!.home!.location!));
      }
      if (state.selectedFishingTrip!.rodPoints.isNotEmpty) {
        for (var point in state.selectedFishingTrip!.rodPoints) {
          if (point.location != null) {
            markers.add(Marker(
                consumeTapEvents: true,
                onTap: () {
                  Utils.showSnack(SnackTypes.Info, point.name, context);
                },
                markerId: MarkerId('point${point.index}'),
                position: point.location!,
                icon: BitmapDescriptor.fromBytes(rodIcon!)));
          }
        }
      }
    }
    return markers;
  }

  Set<Circle> getStatePointCircles(AppState state) {
    //BitmapDescriptor myIcon = await BitmapDescriptor.fromWidget(myDotWidget);
    var circles = <Circle>{};
    if (state.selectedFishingTrip != null) {
      //get fishing trip markers

      if (state.selectedFishingTrip!.rodPoints.isNotEmpty) {
        for (var point in state.selectedFishingTrip!.rodPoints) {
          if (point.location != null) {
            circles.add(Circle(
                consumeTapEvents: true,
                onTap: () {
                  Utils.showSnack(SnackTypes.Info, point.name, context);
                },
                circleId: CircleId('point${point.index}'),
                center: point.location!,
                radius: 1, // set the radius to a small value
                fillColor: point.color,
                strokeWidth: 1,
                strokeColor: Colors.grey));
          }
        }
      }
    }
    return circles;
  }

  void onLongPressMap(LatLng location, AppState state) {
    if (state.selectedFishingTrip == null) {
      Utils.showSnack(
          SnackTypes.Info, "Please select first a fishing trip", context);
      return;
    }
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return ABottomSheet(
              height: 500,
              child: SetTripPointsWidget(
                location: location,
                state: state,
              ));
        });
  }

  // ignore: curly_braces_in_flow_control_structures
  CameraPosition getCameraPosition(AppState state) {
    var defaultPosition = CameraPosition(
      target: getMapCeter(state),
      tilt: 20,
      zoom: 18.0,
    );
    if (state.selectedFishingTrip != null) {
      var tripPosition = state.selectedFishingTrip!.mapPosition;
      if (tripPosition != null) {
        final position = CameraPosition(
          target: LatLng(tripPosition.targetLat, tripPosition.targetLng),
          zoom: tripPosition.zoom,
          bearing: tripPosition.rotation,
        );
        //mapController.animateCamera(CameraUpdate.newCameraPosition(position));
        return position;
      } else {
        return defaultPosition;
      }
    } else {
      return defaultPosition;
    }
  }

  void onCameraMove(CameraPosition position, AppState state) {
    if (state.selectedFishingTrip != null) {
      if (state.selectedFishingTrip!.mapPosition == null) {
        state.selectedFishingTrip!.mapPosition = TripCameraPosition(
            targetLat: position.target.latitude,
            targetLng: position.target.longitude,
            zoom: position.zoom,
            rotation: position.bearing);
      } else {
        var mapPosition = state.selectedFishingTrip!.mapPosition;
        if (mapPosition != null) {
          mapPosition.targetLat = position.target.latitude;
          mapPosition.targetLng = position.target.longitude;
          mapPosition.rotation = position.bearing;
          mapPosition.zoom = position.zoom;
        }
      }
      //save state in cache
      state.saveState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, appState, __) {
      return FractionallySizedBox(
        child: Center(
          child: GoogleMap(
            circles: getStatePointCircles(appState),
            onMapCreated: (GoogleMapController controller) {
              _onMapCreated(controller, appState);
            },
            markers: getStateMarkers(appState),
            zoomControlsEnabled: false,
            //myLocationButtonEnabled: false,
            onLongPress: (LatLng location) {
              onLongPressMap(location, appState);
            },
            onCameraMove: (CameraPosition position) {
              onCameraMove(position, appState);
            },
            mapType: MapType.satellite,
            initialCameraPosition: getCameraPosition(appState),
          ),
        ),
      );
    });
  }
}
