import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/AIconButton.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/theme.dart';
import 'package:smart_boat/ui/base/utils/controls_utils.dart';
import 'package:smart_boat/ui/base/utils/utils.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import '../../ble/ble_device_interactor.dart';
import '../base/ABottomSheet.dart';
import '../models/fishing_trip.dart';
import 'fishing_trip.dart';
import 'map_preview.dart';

class FishingTripPreviewWidget extends StatefulWidget {
  FishingTrip? fishingTrip;
  AppState state;
  final Function(BleDeviceInteractor deviceInteractor,
      ConnectionStateUpdate bleConnectionStatus) startListening;
  FishingTripPreviewWidget(
      {Key? key,
      required this.fishingTrip,
      required this.state,
      required this.startListening})
      : super(key: key);

  @override
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

  void selectFishingTrip(BleDeviceInteractor deviceInteractor,
      ConnectionStateUpdate bleConnectionStatus) {
    if (bleConnectionStatus.connectionState ==
            DeviceConnectionState.connected &&
        bleConnectionStatus.deviceId.isNotEmpty) {
      widget.startListening(deviceInteractor, bleConnectionStatus);
    }
    //set selected fishing trip and update state
    widget.state.setSelectedFishingTrip(widget.fishingTrip!);
  }

  bool isSelected() {
    if (widget.state.selectedFishingTrip == null) return false;
    if (widget.state.selectedFishingTrip!.name == widget.fishingTrip!.name) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConnectionStateUpdate, BleDeviceInteractor>(
        builder: (_, bleConnectionStatus, deviceInteractor, __) {
      return GestureDetector(
        onTap: () {
          selectFishingTrip(deviceInteractor, bleConnectionStatus);
        },
        onLongPress: () {
          if (widget.state.selectedFishingTrip == null) {
            Utils.showSnack(
                SnackTypes.Error, "Please select fishing trip first", context);
            return;
          }
          showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) {
                return ABottomSheet(
                    height: 700,
                    child: FishingTripWidget(
                      fishingTrip: widget.fishingTrip,
                      state: widget.state,
                    ));
              });
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Container(
                  height: 100,
                  width: 100,
                  alignment: Alignment.center,
                  child: MapPreviewWidget(
                      zoom: 10, center: widget.fishingTrip!.home!.location),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: AText(
                                type: ATextTypes.normal,
                                text: widget.fishingTrip!.name),
                          ),
                          isSelected()
                              ? Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  padding: const EdgeInsets.all(5),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                )
                              : const SizedBox()
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: widget.fishingTrip!.rodPoints.length + 1,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 10,
                              mainAxisExtent: 40,
                              // horizontal spacing between the items
                              crossAxisSpacing: 10,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                // Static element
                                return AIconButton(
                                  borderColor:
                                      widget.fishingTrip?.home?.location != null
                                          ? Colors.green
                                          : SmartBoatTheme.of(context)
                                              .primaryBackground,
                                  borderRadius: 10,
                                  fillColor: SmartBoatTheme.of(context)
                                      .primaryBackground,
                                  borderWidth: 1,
                                  //text: "H",
                                  icon: Icon(
                                    Icons.home_filled,
                                    color:
                                        SmartBoatTheme.of(context).primaryText,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    //show list of devices
                                  },
                                );
                              } else {
                                // Generated elements from the list
                                final r =
                                    widget.fishingTrip!.rodPoints[index - 1];
                                return AIconButton(
                                  borderColor: r.location != null
                                      ? Colors.green
                                      : SmartBoatTheme.of(context)
                                          .primaryBackground,
                                  borderRadius: 10,
                                  fillColor: SmartBoatTheme.of(context)
                                      .primaryBackground,
                                  borderWidth: 1,
                                  //text: r.name,
                                  icon: Icon(
                                    Icons.circle,
                                    color: r.color,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    //show list of devices
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      Stack(
        children: [
          Container(
            width: 400,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  selectFishingTrip(deviceInteractor, bleConnectionStatus);
                },
                onLongPress: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return ABottomSheet(
                            height: 700,
                            child: FishingTripWidget(
                              fishingTrip: widget.fishingTrip,
                              state: widget.state,
                            ));
                      });
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: SmartBoatTheme.of(context).primaryBackground),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, top: 10),
                            child: Container(
                              height: 100,
                              width: 100,
                              alignment: Alignment.center,
                              child: MapPreviewWidget(
                                  zoom: 10,
                                  center: widget.fishingTrip!.home!.location),
                            ),
                          ),
                          GridView.builder(
                            itemCount: widget.fishingTrip!.rodPoints.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                // Static element
                                return AIconButton(
                                  borderColor: SmartBoatTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: 10,
                                  fillColor: SmartBoatTheme.of(context)
                                      .primaryBackground,
                                  borderWidth: 1,
                                  text: "Home",
                                  icon: Icon(
                                    Icons.home_filled,
                                    color:
                                        SmartBoatTheme.of(context).primaryText,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    //show list of devices
                                  },
                                );
                              } else {
                                // Generated elements from the list
                                final r =
                                    widget.fishingTrip!.rodPoints[index - 1];
                                return AIconButton(
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
                                    //show list of devices
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      )
                    ]),
                  ),
                ),
              ),
            ),
          ),
          isSelected()
              ? Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    padding: const EdgeInsets.all(5),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                )
              : const SizedBox()
        ],
      );
    });
  }
}
