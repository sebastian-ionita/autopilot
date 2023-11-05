import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/theme.dart';
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

  bool loading = false;
  late GoogleMapController mapController;
  late LocationData? locationDetails = null;

  late Uint8List? boatIcon = null;
  late Uint8List? rodIcon = null;
  late Uint8List? homeIcon = null;

  void _onMapCreated(GoogleMapController controller, AppState appState) {
    mapController = controller;
    appState.setGoogleMapController(controller);
  }

  @override
  void initState() {
    super.initState();

    getLocation().then((location) {
      setState(() {
        locationDetails = location;
      });
      MarkersWithLabel.getBytesFromCanvasDynamic(
              context: context,
              fontSize: 28,
              iconPath: 'lib/assets/icons/boat_icon.png',
              iconSize: const Size(80, 80))
          .then((icon) {
        setState(() {
          boatIcon = icon;
        });
      });

      MarkersWithLabel.getBytesFromCanvasDynamic(
              context: context,
              fontSize: 28,
              iconPath: '',
              iconSize: const Size(80, 80),
              text: 'Rod')
          .then((icon) {
        setState(() {
          rodIcon = icon;
        });
      });

      MarkersWithLabel.getBytesFromCanvasDynamic(
        context: context,
        fontSize: 28,
        iconPath: 'lib/assets/icons/home_icon.png',
        iconSize: const Size(80, 80),
      ).then((icon) {
        setState(() {
          homeIcon = icon;
        });
      });
    });
  }

  Future<LocationData?> getLocation() async {
    //check location permissions
    setState(() {
      loading = true;
    });
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          loading = false;
        });
        // ignore: use_build_context_synchronously
        Utils.showSnack(
            SnackTypes.Info, "Please enable location on the device", context);
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          loading = false;
        });
        // ignore: use_build_context_synchronously
        Utils.showSnack(
            SnackTypes.Info,
            "This app required location permission, in order to be used!",
            context);
        return null;
      }
    }
    var locationData = await location.getLocation();
    setState(() {
      loading = false;
    });
    return locationData;
  }

  LatLng getMapCeter(AppState state) {
    return state.boatLocation != null
        ? state.boatLocation!
        : locationDetails != null
            ? LatLng(locationDetails!.latitude!, locationDetails!.longitude!)
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

  Set<Polyline> getPolylines(AppState state) {
    final Set<Polyline> polylines = {};
    if (state.selectedFishingTrip != null) {
      var routine = state.selectedFishingTrip!.routine!;
      if (routine.running) {
        final List<LatLng> points = [];
        if (routine.routinePath.isNotEmpty) {
          points.addAll(routine.routinePath);
          polylines.add(Polyline(
            polylineId: const PolylineId('routine_path'),
            visible: true,
            points: points,
            width: 4,
            color: Colors.blue,
          ));
        }
      }
    }
    return polylines;
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
              height: 600,
              child: SetTripPointsWidget(
                location: location,
                state: state,
              ));
        });
  }

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
      return Scaffold(
        body: Container(
          width: double.infinity,
          color: SmartBoatTheme.of(context).primaryBackground,
          child: loading
              ? Center(
                  child: CircularProgressIndicator(
                      color: SmartBoatTheme.of(context).primaryTextColor),
                )
              : locationDetails == null
                  ? Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: AText(
                                type: ATextTypes.smallHeading,
                                text: "Location not enabled",
                                textAlign: TextAlign.center,
                                color:
                                    SmartBoatTheme.of(context).primaryTextColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: AText(
                                type: ATextTypes.normal,
                                textAlign: TextAlign.center,
                                text:
                                    "Please make sure location services on this devices are enabled, and permissions to access location are allowed for this application.",
                                color: SmartBoatTheme.of(context)
                                    .secondaryTextColor,
                              ),
                            )
                          ]),
                    )
                  : GoogleMap(
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
                      mapType: MapType.hybrid,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      polylines: getPolylines(appState),
                      initialCameraPosition: getCameraPosition(appState),
                    ),
        ),
      );
    });
  }
}
