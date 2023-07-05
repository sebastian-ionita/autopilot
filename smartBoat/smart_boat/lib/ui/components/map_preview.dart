import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_boat/ui/base/AText.dart';

class MapPreviewWidget extends StatefulWidget {
  final LatLng? center;
  final double zoom;
  const MapPreviewWidget({Key? key, required this.center, required this.zoom})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MapPreviewWidgetState createState() => _MapPreviewWidgetState();
}

class _MapPreviewWidgetState extends State<MapPreviewWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.center != null
        ? GoogleMap(
            onMapCreated: _onMapCreated,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapType: MapType.satellite,
            initialCameraPosition: CameraPosition(
              target: widget.center!,
              tilt: 20,
              zoom: widget.zoom,
            ),
          )
        : AText(
            textAlign: TextAlign.center,
            text: "Set a home to show a map",
            type: ATextTypes.soSmall,
          );
  }
}
