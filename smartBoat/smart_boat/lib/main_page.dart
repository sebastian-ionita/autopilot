import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:smart_boat/ui/base/theme.dart';
import 'package:smart_boat/ui/ble_notallowed_screen.dart';
import 'package:smart_boat/ui/home_page.dart';

class MainPageWidget extends StatefulWidget {
  const MainPageWidget({Key? key}) : super(key: key);

  @override
  _MainPageWidgetState createState() => _MainPageWidgetState();
}

class _MainPageWidgetState extends State<MainPageWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      Consumer2<BleStatus?, ConnectionStateUpdate>(
        builder: (_, status, connectionStateUpdate, __) {
          return Scaffold(
            key: scaffoldKey,
            backgroundColor: SmartBoatTheme.of(context).primaryBackground,
            body: Container(
                child: (status == BleStatus.ready)
                    ? const HomePageWidget()
                    : BleNotAllowedScreen(status: status ?? BleStatus.unknown)),
          );
        },
      );
}
