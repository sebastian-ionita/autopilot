import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_boat/ui/base/theme.dart';
import '../base/AText.dart';

class ARoundedButton extends StatefulWidget {
  final ARoundedButtonTypes type;
  final String buttonText;
  final Icon icon;
  final Future<void> Function() onPressed;
  Future<void> Function()? onLongPressed;

  final bool? disabled;
  ARoundedButton({
    required this.type,
    required this.icon,
    required this.buttonText,
    required this.onPressed,
    this.disabled,
    this.onLongPressed,
    Key? key,
  }) : super(key: key);

  @override
  _ARoundedButtonState createState() => _ARoundedButtonState();
}

class _ARoundedButtonState extends State<ARoundedButton> {
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
      HapticFeedback.heavyImpact();
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
        type: ATextTypes.small,
        text: text,
        color: SmartBoatTheme.of(context).thirdTextColor,
        fontWeight: FontWeight.w500);
  }

  Color getButtonColorPrimary() {
    if (widget.disabled != null && widget.disabled == true) return Colors.grey;
    switch (widget.type) {
      case ARoundedButtonTypes.primary:
        return SmartBoatTheme.of(context).roundedButtonPrimary;
      case ARoundedButtonTypes.secondary:
        return SmartBoatTheme.of(context).roundedButtonSecondary;
      default:
        return const Color(0x00FFFFFF);
    }
  }

  double getElevation() {
    switch (widget.type) {
      case ARoundedButtonTypes.primary:
        return 2;
      default:
        return 0;
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
    return ElevatedButton.icon(
      icon: widget.icon,
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(
              color: Colors.transparent,
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
                  strokeWidth: 2.0, color: circularProgressIndicatorColor()),
            )
          : getButtonText(widget.buttonText),
    );
  }
}

enum ARoundedButtonTypes { primary, secondary }
