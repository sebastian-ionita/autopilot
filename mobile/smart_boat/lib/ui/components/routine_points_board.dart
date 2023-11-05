// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/models/app_state.dart';
import 'package:smart_boat/ui/models/map_point.dart';
import '../base/theme.dart';

// ignore: must_be_immutable
class RoutinePointsBoardWidget extends StatefulWidget {
  final Future<void> Function(Point point) onSelect;
  const RoutinePointsBoardWidget({required this.onSelect, Key? key})
      : super(key: key);

  @override
  _RoutinePointsBoardWidgetState createState() =>
      _RoutinePointsBoardWidgetState();
}

class _RoutinePointsBoardWidgetState extends State<RoutinePointsBoardWidget> {
  double boardHeight = 150;
  double boardWidth = 300;
  @override
  void initState() {
    super.initState();
  }

  Widget _createPoint(Point point) {
    if (point.name == "Home") {
      return GestureDetector(
        onTap: () async {
          await widget.onSelect(point);
        },
        child: SizedBox(
            width: 35,
            height: 38,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Image.asset(
                'lib/assets/icons/home_icon.png',
                width: 30, // Adjust the size as needed
                height: 35, // Adjust the size as needed
                fit: BoxFit.fill,
              ),
            )),
      );
    }
    return GestureDetector(
      onTap: () async {
        await widget.onSelect(point);
      },
      child: SizedBox(
        width: 50,
        height: 40,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 3),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  color: SmartBoatTheme.of(context).primaryButtonDisabledColor),
              child: AText(
                  type: ATextTypes.small,
                  color: SmartBoatTheme.of(context).primaryTextColor,
                  text: point.name),
            ),
            Container(
              width: 10, // Adjust the point size as needed
              height: 10, // Adjust the point size as needed
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: point.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLine(List<Point> points) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: points.map((point) => _createPoint(point)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTriangle(List<Point> points) {
    return Stack(
      children: [
        Positioned(
            top: boardHeight / 2 + 10,
            left: boardWidth / 2 - 20,
            child: _createPoint(points[0])),
        Positioned(top: 20, left: 40, child: _createPoint(points[1])),
        Positioned(
            top: 20, left: boardWidth - 80, child: _createPoint(points[2])),
      ],
    );
  }

  Widget _buildRectangle(List<Point> points) {
    return Stack(
      children: points
          .asMap()
          .entries
          .map((entry) => Positioned(
                top: entry.key < 2 ? 20 : boardHeight - 60,
                left: entry.key % 2 == 0 ? 40 : boardWidth - 90,
                child: _createPoint(entry.value),
              ))
          .toList(),
    );
  }

  Widget _buildPolygon(List<Point> points) {
    return Stack(children: [
      ...points
          .take(4)
          .toList()
          .asMap()
          .entries
          .map((entry) => Positioned(
                top: entry.key < 2 ? 20 : boardHeight - 60,
                left: entry.key % 2 == 0 ? 40 : boardWidth - 90,
                child: _createPoint(entry.value),
              ))
          .toList(),
      Positioned(
          top: boardHeight / 2 - 30,
          left: boardWidth / 2 - 20,
          child: _createPoint(points[4])) //add also last point in the middle
    ]);
  }

  Widget getPointsBoard(AppState appState) {
    Widget boardWidget;

    var selectedFishingTrip = appState.selectedFishingTrip;
    var availablePoints = selectedFishingTrip!.rodPoints
        .where((rp) => rp.location != null)
        .toList();
    if (availablePoints.isEmpty) {
      boardWidget = Center(
          child: AText(
              text: "Please select points on the map",
              color: SmartBoatTheme.of(context).primaryTextColor,
              type: ATextTypes.normal));
    }
    if (selectedFishingTrip.home != null &&
        selectedFishingTrip.home!.location != null) {
      availablePoints.add(selectedFishingTrip.home!);
    }
    if (availablePoints.isNotEmpty) {
      if (availablePoints.length == 2) {
        boardWidget = _buildLine(availablePoints);
      } else if (availablePoints.length == 3) {
        boardWidget = _buildTriangle(availablePoints);
      } else if (availablePoints.length == 4) {
        boardWidget = _buildRectangle(availablePoints);
      } else if (availablePoints.length == 5) {
        boardWidget = _buildPolygon(availablePoints);
      } else {
        boardWidget = Center(
            child: AText(
                text: "Configuration issue, too many points found.",
                color: SmartBoatTheme.of(context).primaryTextColor,
                type: ATextTypes.small));
      }
      return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: SmartBoatTheme.of(context).primaryButtonDisabledColor,
              width: 1,
            ),
          ),
          height: boardHeight,
          width: boardWidth,
          child: Stack(
            children: [boardWidget],
          ));
    } else {
      return Center(
          child: AText(
              text: "Please select points on the map",
              color: SmartBoatTheme.of(context).primaryTextColor,
              type: ATextTypes.normal));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, appState, __) {
      return getPointsBoard(appState);
    });
  }
}
