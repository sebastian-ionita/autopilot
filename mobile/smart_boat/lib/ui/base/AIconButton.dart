import 'package:flutter/material.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/theme.dart';

class AIconButton extends StatelessWidget {
  const AIconButton(
      {Key? key,
      this.borderColor,
      this.borderRadius,
      this.borderWidth,
      this.fillColor,
      required this.icon,
      this.text,
      this.onLongPressed,
      this.onPressed})
      : super(key: key);

  final double? borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderWidth;
  final Widget icon;
  final String? text;
  final void Function()? onPressed;
  final void Function()? onLongPressed;

  @override
  Widget build(BuildContext context) => Material(
        borderRadius:
            borderRadius != null ? BorderRadius.circular(borderRadius!) : null,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            color: fillColor,
            border: Border.all(
              color: borderColor ?? Colors.transparent,
              width: borderWidth ?? 0,
            ),
            borderRadius: borderRadius != null
                ? BorderRadius.circular(borderRadius!)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onLongPress: onLongPressed,
                child: IconButton(
                  icon: icon,
                  onPressed: onPressed,
                ),
              ),
              text == null
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: AText(
                        type: ATextTypes.small,
                        text: text!,
                        color: SmartBoatTheme.of(context).primaryText,
                      ),
                    )
            ],
          ),
        ),
      );
}
