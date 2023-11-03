import 'package:flutter/material.dart';
import 'package:smart_boat/ui/base/theme.dart';
import '../base/AText.dart';

class ASelectableButton extends StatefulWidget {
  final ASelectableButtonTypes type;
  final String buttonText;
  final bool selected;
  Icon? icon;
  final Future<void> Function() onPressed;
  Future<void> Function()? onLongPressed;

  final bool? disabled;
  ASelectableButton({
    required this.type,
    required this.selected,
    this.icon,
    required this.buttonText,
    required this.onPressed,
    this.disabled,
    this.onLongPressed,
    Key? key,
  }) : super(key: key);

  @override
  _ASelectableButtonState createState() => _ASelectableButtonState();
}

class _ASelectableButtonState extends State<ASelectableButton> {
  @override
  void dispose() {
    super.dispose();
  }

  bool _loading = false;

  Future<void> onClick() async {
    setState(() {
      _loading = true;
    });
    try {
      await widget.onPressed();
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

  Widget getButtonText(String text) {
    if (text.isEmpty) return const SizedBox();
    return AText(
        type: ATextTypes.normal,
        text: text,
        color: widget.selected
            ? SmartBoatTheme.of(context).selectedTextColor
            : SmartBoatTheme.of(context).secondaryTextColor,
        fontWeight: FontWeight.w500);
  }

  Color getButtonColorPrimary() {
    if (widget.disabled != null && widget.disabled == true) return Colors.grey;
    switch (widget.type) {
      case ASelectableButtonTypes.primary:
        return SmartBoatTheme.of(context).primaryButtonDisabledColor;

      default:
        return const Color(0x00FFFFFF);
    }
  }

  double getElevation() {
    switch (widget.type) {
      case ASelectableButtonTypes.primary:
        return 0;
      default:
        return 0;
    }
  }

  double getButtonHeight() {
    switch (widget.type) {
      case ASelectableButtonTypes.primary:
        return 55;
      case ASelectableButtonTypes.primarySmall:
        return 30;
    }
  }

  Color circularProgressIndicatorColor() {
    switch (widget.type) {
      default:
        return SmartBoatTheme.of(context).primaryTextColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    Icon? btnIcon = null;
    if (widget.icon != null) {
      btnIcon = Icon(
          IconData(widget.icon!.icon!.codePoint,
              fontFamily: widget.icon!.icon!.fontFamily),
          size: 20,
          color: widget.icon!.color ??
              (widget.selected
                  ? SmartBoatTheme.of(context).selectedTextColor
                  : SmartBoatTheme.of(context).secondaryTextColor));
    }
    return btnIcon != null
        ? ElevatedButton.icon(
            icon: btnIcon,
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: widget.selected
                        ? SmartBoatTheme.of(context).selectedTextColor
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(10),
                backgroundColor: getButtonColorPrimary(),
                elevation: getElevation(),
                minimumSize: Size.fromHeight(getButtonHeight())),
            onLongPress: widget.onLongPressed,
            onPressed: () async {
              if (widget.disabled != null && widget.disabled == true) {
                return; //do nothing because the button is disabled
              }
              await onClick();
            },
            label: _loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: circularProgressIndicatorColor()),
                  )
                : getButtonText(widget.buttonText),
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: widget.selected
                        ? SmartBoatTheme.of(context).selectedTextColor
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(10),
                backgroundColor: getButtonColorPrimary(),
                elevation: getElevation(),
                minimumSize: Size.fromHeight(getButtonHeight())),
            onLongPress: widget.onLongPressed,
            onPressed: () async {
              if (widget.disabled != null && widget.disabled == true) {
                return; //do nothing because the button is disabled
              }
              await onClick();
            },
            child: _loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: circularProgressIndicatorColor()),
                  )
                : getButtonText(widget.buttonText),
          );
  }
}

enum ASelectableButtonTypes { primary, primarySmall }
