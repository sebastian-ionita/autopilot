import 'package:flutter/material.dart';
import 'package:smart_boat/ui/base/AText.dart';
import 'package:smart_boat/ui/base/theme.dart';

class AIconButton extends StatefulWidget {
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
  final Future<void> Function()? onPressed;
  final Future<void> Function()? onLongPressed;

  @override
  _AIconButtonState createState() => _AIconButtonState();
}

class _AIconButtonState extends State<AIconButton> {
  bool _loading = false;

  Future<void> onPressedClick() async {
    setState(() {
      _loading = true;
    });
    try {
      await widget.onPressed!();
    } catch (e) {
      setState(() {
        _loading = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> onLongPressedClick() async {
    setState(() {
      _loading = true;
    });
    try {
      await widget.onLongPressed!();
    } catch (e) {
      setState(() {
        _loading = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Material(
        borderRadius: widget.borderRadius != null
            ? BorderRadius.circular(widget.borderRadius!)
            : null,
        color: SmartBoatTheme.of(context).primaryBackground,
        clipBehavior: Clip.antiAlias,
        child: _loading
            ? CircularProgressIndicator(strokeWidth: 4)
            : Ink(
                decoration: BoxDecoration(
                  color: widget.fillColor,
                  border: Border.all(
                    color: widget.borderColor ?? Colors.transparent,
                    width: widget.borderWidth ?? 0,
                  ),
                  borderRadius: widget.borderRadius != null
                      ? BorderRadius.circular(widget.borderRadius!)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onLongPress: () async {
                        if (widget.onLongPressed != null) {
                          await onLongPressedClick();
                        }
                      },
                      child: IconButton(
                        color: SmartBoatTheme.of(context).selectedTextColor,
                        icon: widget.icon,
                        onPressed: () async {
                          if (widget.onPressed != null) {
                            await onPressedClick();
                          }
                        },
                      ),
                    ),
                    widget.text == null
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: AText(
                              type: ATextTypes.small,
                              text: widget.text!,
                              color: SmartBoatTheme.of(context).primaryText,
                            ),
                          )
                  ],
                ),
              ),
      );
}
