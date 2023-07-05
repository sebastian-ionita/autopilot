import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:smart_boat/ui/components/fishing_trip_preview.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import '../../ble/ble_device_interactor.dart';
import 'add_fishing_trip.dart';

// ignore: must_be_immutable
class ActionsContainerWidget extends StatefulWidget {
  AppState state;
  final Function(BleDeviceInteractor deviceInteractor,
      ConnectionStateUpdate bleConnectionStatus) startListening;
  ActionsContainerWidget(
      {Key? key, required this.state, required this.startListening})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ActionsContainerWidgetState createState() => _ActionsContainerWidgetState();
}

class _ActionsContainerWidgetState extends State<ActionsContainerWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  List<Widget> getCarouselItems() {
    var fishingTrips = widget.state.fishingTrips
        .map((f) => FishingTripPreviewWidget(
              startListening: widget.startListening,
              fishingTrip: f,
              state: widget.state,
            ))
        .toList();
    return [
      ...fishingTrips,
      AddFishingTripWidget(
        state: widget.state,
      )
    ];
  }

  int carouselItemsLength() {
    return widget.state.fishingTrips.length + 1;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.35,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            height: 20,
          ),
          CarouselIndicator(
            count: carouselItemsLength(),
            index: pageIndex,
          ),
          Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  CarouselSlider(
                      items: getCarouselItems(),
                      options: CarouselOptions(
                        viewportFraction: 1,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            pageIndex = index;
                          });
                        },
                        scrollDirection: Axis.horizontal,
                      )),
                ],
              )),
        ],
      ),
    );
  }
}
