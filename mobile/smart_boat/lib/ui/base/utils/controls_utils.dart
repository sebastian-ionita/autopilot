import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class UpperCaseFirstLetterTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.length > 0
          ? "${newValue.text[0].toUpperCase()}${newValue.text.substring(1)}"
          : newValue.text,
      selection: newValue.selection,
    );
  }
}

class UpperCaseFirstLetterEveryWordTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var words = newValue.text.split(" ");
    var newString = words.map((e) => e.trim().capitalize()).join(" ");
    return TextEditingValue(
      text: newString,
      selection: newValue.selection,
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (this.length > 0)
      return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
    else
      return this;
  }
}
