import 'package:flutter/material.dart';

import 'AButton.dart';
import 'AText.dart';

class AConfirmation extends StatefulWidget {
  final String text;
  String? title;
  final Future<void> Function() confirm;
  AConfirmation(
      {Key? key, required this.text, required this.confirm, this.title})
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
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AText(type: ATextTypes.normal, text: "Confirmation needed"),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: AText(type: ATextTypes.small, text: widget.text),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 15),
          child: Row(children: [
            AButton(
              buttonText: "Cancel",
              type: AButtonTypes.secondary,
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
            AButton(
              buttonText: "Yes",
              type: AButtonTypes.primary,
              onPressed: () async {
                await widget.confirm();
                Navigator.pop(context); //close the bottom sheet
              },
            ),
          ]),
        )
      ],
    );
  }
}
