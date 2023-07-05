import 'package:flutter/material.dart';
import 'package:smart_boat/ui/base/theme.dart';

import 'AText.dart';

class AButton extends StatefulWidget {
  final AButtonTypes type;
  final String buttonText;
  final Future<void> Function() onPressed;
  final bool? linkText;
  final bool? disabled;
  const AButton({
    required this.type,
    required this.buttonText,
    required this.onPressed,
    this.linkText,
    this.disabled,
    Key? key,
  }) : super(key: key);

  @override
  _AButtonState createState() => _AButtonState();
}

class _AButtonState extends State<AButton> {
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
    switch (widget.type) {
      case AButtonTypes.primary:
        return AText(
            type: ATextTypes.small,
            text: text,
            color: SmartBoatTheme.of(context).secondaryText,
            fontWeight: FontWeight.w500);
      case AButtonTypes.heading:
      case AButtonTypes.headingSelected:
        return AText(
            type: ATextTypes.small,
            text: text,
            color: SmartBoatTheme.of(context).primaryColor);
      case AButtonTypes.secondarySmall:
        return AText(
            type: ATextTypes.small,
            text: text,
            color: SmartBoatTheme.of(context).primaryColor);
      case AButtonTypes.secondary:
      default:
        return AText(
            type: ATextTypes.small,
            text: text,
            color: widget.linkText != null && widget.linkText == true
                ? SmartBoatTheme.of(context).primaryText
                : SmartBoatTheme.of(context).primaryText,
            fontWeight: FontWeight.bold);
    }
  }

  Color getButtonColorPrimary() {
    if (widget.disabled != null && widget.disabled == true) return Colors.grey;
    switch (widget.type) {
      case AButtonTypes.primary:
        return SmartBoatTheme.of(context).primaryButtonColor;
      case AButtonTypes.secondary:
        return Colors.transparent;
      case AButtonTypes.headingSelected:
        return const Color.fromARGB(255, 255, 255, 255);
      /*    case AButtonTypes.secondarySmall:
        return Color.fromARGB(255, 255, 255, 255); */
      default:
        return const Color(0x00FFFFFF);
    }
  }

  Color getShadowColor() {
    switch (widget.type) {
      case AButtonTypes.primary:
        return SmartBoatTheme.of(context).secondaryBackground;
      default:
        return const Color(0x00FFFFFF);
    }
  }

  double getElevation() {
    switch (widget.type) {
      case AButtonTypes.primary:
        return 2;
      default:
        return 0;
    }
  }

  double getButtonHeight() {
    switch (widget.type) {
      case AButtonTypes.secondarySmall:
        return 10;
      default:
        return 35;
    }
  }

  Color circularProgressIndicatorColor() {
    switch (widget.type) {
      case AButtonTypes.primary:
        return SmartBoatTheme.of(context).primaryBackground;
      case AButtonTypes.secondary:
        return SmartBoatTheme.of(context).secondaryBackground;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                  color: Colors.transparent,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(15),
              backgroundColor: getButtonColorPrimary(),
              shadowColor: getShadowColor(),
              elevation: getElevation(),
              minimumSize: Size.fromHeight(getButtonHeight())),
          onPressed: () async {
            if (widget.disabled != null && widget.disabled == true) {
              return; //do nothing because the button is disabled
            }
            await onClick();
          },
          child: _loading
              ? CircularProgressIndicator(
                  strokeWidth: 2.0, color: circularProgressIndicatorColor())
              : getButtonText(widget.buttonText)),
    );
  }
}

enum AButtonTypes {
  primary,
  secondary,
  secondarySmall,
  heading,
  headingSelected
}
