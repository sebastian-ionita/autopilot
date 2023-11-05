import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_boat/ui/base/theme.dart';

class InputDoneView extends StatelessWidget {
  Future<void> Function() doneAction;
  InputDoneView({Key? key, required this.doneAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        color: SmartBoatTheme.of(context).primaryButtonDisabledColor,
        child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: CupertinoButton(
                padding:
                    const EdgeInsets.only(right: 24.0, top: 8.0, bottom: 8.0),
                onPressed: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  await doneAction();
                },
                child: Text("Done",
                    style: TextStyle(
                      color: SmartBoatTheme.of(context).primaryTextColor,
                    )),
              ),
            )));
  }
}
