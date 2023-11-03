import 'package:flutter/material.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/components/fishing_trip.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import '../base/ABottomSheet.dart';
import '../base/AIconButton.dart';
import '../base/theme.dart';

class AddFishingTripWidget extends StatefulWidget {
  AppState state;
  AddFishingTripWidget({Key? key, required this.state}) : super(key: key);

  @override
  _AddFishingTripWidgetState createState() => _AddFishingTripWidgetState();
}

class _AddFishingTripWidgetState extends State<AddFishingTripWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 50,
            child: AIconButton(
              borderColor: SmartBoatTheme.of(context).primaryBackground,
              borderRadius: 10,
              fillColor: SmartBoatTheme.of(context).primaryBackground,
              borderWidth: 1,
              icon: Icon(
                Icons.add,
                color: SmartBoatTheme.of(context).primaryText,
                size: 20,
              ),
              onPressed: () async {
                //show list of devices
                await showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (bottomSheetContext) {
                      return ABottomSheet(
                          height: 700,
                          child: FishingTripWidget(
                            parentContext: bottomSheetContext,
                            fishingTrip: null,
                          ));
                    });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AText(
              type: ATextTypes.normal,
              text: "Add fishing trip",
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
