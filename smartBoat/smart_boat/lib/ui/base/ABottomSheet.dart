import 'package:smart_boat/ui/base/theme.dart';
import 'package:flutter/material.dart';

class ABottomSheet extends StatefulWidget {
  final Widget child;
  final double height;
  const ABottomSheet({required this.child, required this.height, Key? key})
      : super(key: key);

  @override
  _ABottomSheetState createState() => _ABottomSheetState();
}

class _ABottomSheetState extends State<ABottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
          width: double.infinity,
          height: widget.height,
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          decoration: BoxDecoration(
            color: SmartBoatTheme.of(context).secondaryBackground,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: SmartBoatTheme.of(context).lineColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: widget.child,
              ),
            )
          ])),
    );
  }
}
