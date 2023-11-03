import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:print_color/print_color.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/AIconButton.dart';
import 'package:smart_boat/ui/base/theme.dart';
import 'package:smart_boat/ui/components/fishing_trip_preview.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import '../base/ABottomSheet.dart';
import 'fishing_trip.dart';

// ignore: must_be_immutable
class ActionsContainerWidget extends StatefulWidget {
  ActionsContainerWidget({Key? key}) : super(key: key);

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

  List<Widget> getCarouselItems(AppState state) {
    var fishingTrips = state.fishingTrips
        .map((f) => FishingTripPreviewWidget(
              fishingTrip: f,
            ))
        .toList();
    return [
      ...fishingTrips,
    ];
  }

  int carouselItemsLength(AppState state) {
    return state.fishingTrips.length;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, appState, __) {
      return Container(
        margin: const EdgeInsets.only(left: 5, bottom: 9),
        height: 90,
        width: 250,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            appState.fishingTrips.isNotEmpty
                ? Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CarouselIndicator(
                          count: carouselItemsLength(appState),
                          color: SmartBoatTheme.of(context).primaryTextColor,
                          activeColor:
                              SmartBoatTheme.of(context).selectedTextColor,
                          index: appState.selectedFishingTripIndex,
                        ),
                        CarouselSlider(
                            items: getCarouselItems(appState),
                            options: CarouselOptions(
                              viewportFraction: 1,
                              initialPage: appState.selectedFishingTripIndex!,
                              enableInfiniteScroll: true,
                              reverse: false,
                              height: 60,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  pageIndex = index;
                                });
                                var fishingTrip = appState.fishingTrips[index];
                                appState.setSelectedFishingTrip(fishingTrip);
                              },
                              scrollDirection: Axis.horizontal,
                            )),
                      ],
                    ),
                  )
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 5),
              child: AIconButton(
                borderRadius: 30,
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (bottomSheetContext) {
                        return ABottomSheet(
                            height: 500,
                            child: FishingTripWidget(
                              parentContext: bottomSheetContext,
                              fishingTrip: null,
                            ));
                      });
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
