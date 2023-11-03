import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/theme.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import '../../ble/ble_device_interactor.dart';
import '../base/ABottomSheet.dart';
import '../models/fishing_trip.dart';
import 'fishing_trip.dart';

class FishingTripPreviewWidget extends StatefulWidget {
  FishingTrip? fishingTrip;

  FishingTripPreviewWidget({Key? key, required this.fishingTrip})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FishingTripPreviewWidgetState createState() =>
      _FishingTripPreviewWidgetState();
}

class _FishingTripPreviewWidgetState extends State<FishingTripPreviewWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AppState, ConnectionStateUpdate, BleDeviceInteractor>(
        builder: (_, appState, bleConnectionStatus, deviceInteractor, __) {
      return GestureDetector(
        onTap: () {
          showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (bottomSheetContext) {
                return ABottomSheet(
                    height: 500,
                    child: FishingTripWidget(
                      parentContext: bottomSheetContext,
                      fishingTrip: widget.fishingTrip,
                    ));
              });
        },
        onLongPress: () {},
        child: Container(
          padding: const EdgeInsets.only(right: 10, left: 5),
          decoration: BoxDecoration(
              color: SmartBoatTheme.of(context).primaryBackground,
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: AText(
                    type: ATextTypes.normal,
                    color: SmartBoatTheme.of(context).primaryTextColor,
                    text: widget.fishingTrip!.name),
              )
            ],
          ),
        ),
      );
    });
  }
}
