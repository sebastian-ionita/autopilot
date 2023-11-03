import 'package:flutter/material.dart';
import 'package:smart_boat/ui/base/theme.dart';
import '../base/AText.dart';

class ATextButton extends StatefulWidget {
  final ATextButtonypes type;
  final String buttonText;
  final Future<void> Function() onPressed;
  final bool? disabled;

  const ATextButton({
    required this.type,
    required this.buttonText,
    required this.onPressed,
    this.disabled,
    Key? key,
  }) : super(key: key);

  @override
  _ATextButtonState createState() => _ATextButtonState();
}

class _ATextButtonState extends State<ATextButton> {
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
    return AText(
        type: ATextTypes.normal,
        text: text,
        color: widget.type == ATextButtonypes.secondary
            ? SmartBoatTheme.of(context).primaryTextColor
            : SmartBoatTheme.of(context).selectedTextColor,
        fontWeight: FontWeight.w500);
  }

  Color getButtonColorPrimary() {
    if (widget.disabled != null && widget.disabled == true) return Colors.grey;
    switch (widget.type) {
      case ATextButtonypes.primary:
        return SmartBoatTheme.of(context).roundedButtonPrimary;
      case ATextButtonypes.secondary:
        return SmartBoatTheme.of(context).roundedButtonSecondary;
      default:
        return const Color(0x00FFFFFF);
    }
  }

  double getButtonHeight() {
    return 36;
  }

  Color circularProgressIndicatorColor() {
    switch (widget.type) {
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(
              color: Colors.transparent,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(10),
          backgroundColor: Colors.transparent,
          elevation: 0,
          minimumSize: Size.fromHeight(getButtonHeight())),
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
                  strokeWidth: 2.0, color: circularProgressIndicatorColor()),
            )
          : getButtonText(widget.buttonText),
    );
  }
}

enum ATextButtonypes { primary, secondary }
