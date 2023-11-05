import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_boat/ui/base/theme.dart';
import '../new_base/ATextButton.dart';
import 'AButton.dart';
import 'AText.dart';

class AConfirmation extends StatefulWidget {
  final String text;
  String? title;
  String? okText;
  String? cancelText;
  final Future<void> Function() confirm;
  AConfirmation(
      {Key? key,
      required this.text,
      required this.confirm,
      this.title,
      this.okText,
      this.cancelText})
      : super(key: key);

  @override
  _AConfirmationState createState() => _AConfirmationState();
}

class _AConfirmationState extends State<AConfirmation> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: double.infinity,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: AText(
                type: ATextTypes.smallHeading,
                text: widget.title ?? "Confirmation needed",
                color: SmartBoatTheme.of(context).primaryTextColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: AText(
                type: ATextTypes.normal,
                textAlign: TextAlign.center,
                text: widget.text,
                color: SmartBoatTheme.of(context).secondaryTextColor,
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 15),
          child: Row(children: [
            Expanded(
              child: ATextButton(
                buttonText: widget.cancelText ?? "Cancel",
                type: ATextButtonypes.secondary,
                onPressed: () async {
                  HapticFeedback.heavyImpact();
                  Navigator.pop(context);
                },
              ),
            ),
            Container(
              height: 30,
              width: 1,
              color: SmartBoatTheme.of(context).dividerColor,
            ),
            Expanded(
              child: ATextButton(
                buttonText: widget.okText ?? "Yes",
                type: ATextButtonypes.primary,
                onPressed: () async {
                  HapticFeedback.heavyImpact();
                  await widget.confirm();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context); //close the bottom sheet
                },
              ),
            ),
          ]),
        )
      ],
    );
  }
}
