import 'package:flutter/material.dart';

class AText extends StatelessWidget {
  final ATextTypes type;
  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  AText(
      {Key? key,
      required this.type,
      required this.text,
      this.color,
      this.textAlign,
      this.fontWeight})
      : super(key: key);

  double getFontSize(ATextTypes type) {
    switch (type) {
      case ATextTypes.heading:
        return 32;
      case ATextTypes.small:
        return 13;
      case ATextTypes.normal:
        return 15;
      case ATextTypes.soSmall:
        return 10;
      case ATextTypes.smallHeading:
        return 20;
    }
  }

  FontWeight getFontWeight(ATextTypes type) {
    switch (type) {
      case ATextTypes.heading:
      case ATextTypes.normal:
      case ATextTypes.smallHeading:
        return FontWeight.w500;
      case ATextTypes.small:
      case ATextTypes.soSmall:
        return FontWeight.normal;
    }
  }

  Color getColor(ATextTypes type) {
    switch (type) {
      case ATextTypes.heading:
      case ATextTypes.normal:
      case ATextTypes.smallHeading:
        return const Color(0xFF0F1113);
      case ATextTypes.small:
      case ATextTypes.soSmall:
        return const Color(0xFF57636C);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.left,
      style: TextStyle(
        fontFamily: 'AZOSans',
        color: color ?? getColor(type),
        fontSize: getFontSize(type),
        fontWeight: fontWeight != null ? fontWeight : getFontWeight(type),
      ),
    );
  }
}

enum ATextTypes { heading, smallHeading, normal, small, soSmall }
