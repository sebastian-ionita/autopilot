import 'package:flutter/material.dart';
import 'package:smart_boat/ui/base/ADropdown/ADropdown.dart';
import '../AText.dart';
import '../ATextField/ATextField.dart';

// ignore: must_be_immutable
class ABaseDropdown<T> extends StatefulWidget {
  ABaseDropdown({
    super.key,
    this.initialOption,
    required this.hintText,
    required this.options,
    required this.onChanged,
    required this.disabled,
    this.icon,
    this.fillColor,
    this.validator,
    required this.textStyle,
    required this.elevation,
    this.margin,
  });

  AOption<T>? initialOption;
  final String hintText;
  final List<AOption<T>> options;
  final String? Function(AOption<T>?)? validator;
  final Function(AOption<T>?) onChanged;
  final Widget? icon;
  final bool disabled;
  final Color? fillColor;
  final TextStyle textStyle;
  final double elevation;
  EdgeInsetsGeometry? margin;

  @override
  State<ABaseDropdown<T>> createState() => _ABaseDropdownState<T>();
}

class _ABaseDropdownState<T> extends State<ABaseDropdown<T>> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //check if dropdown value between dropdown options, else null
    if (widget.initialOption != null) {
      if (widget.options
          .any((element) => element.value == widget.initialOption!.value))
        widget.initialOption = widget.options.firstWhere(
            (element) => element.value == widget.initialOption!.value);
      else
        widget.initialOption = null;
    }

    final dropdownWidget = DropdownButtonFormField<AOption<T>>(
      value: widget.initialOption,
      validator: widget.validator,
      decoration: InputDecoration(
        errorStyle: const TextStyle(
          fontFamily: 'Outfit',
          color: Color.fromARGB(255, 203, 104, 99),
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 203, 104, 99),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 203, 104, 99),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Outfit',
          color: Color(0xFF57636C),
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        //hintText: widget.placeholder,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFF1F4F8),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFFF1F4F8),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
      ),
      hint: AText(
          text: widget.hintText,
          type: ATextTypes.small,
          color: Color(0xFF57636C)),
      items: widget.options
          .map((e) => DropdownMenuItem<AOption<T>>(
              value: e,
              child: AText(
                text: e.label,
                type: ATextTypes.small,
                color: Colors.black,
              )))
          .toList(),
      elevation: widget.elevation.toInt(),
      onChanged: (value) {
        widget.initialOption = value;
        widget.onChanged(value);
      },
      icon: widget.icon,
      isExpanded: true,
      dropdownColor: widget.fillColor,
      focusColor: Colors.transparent,
    );

    final disabledText = ATextField(
        type: ATextFieldTypes.text,
        controller: TextEditingController(
            text: widget.initialOption != null
                ? widget.initialOption!.label
                : ''),
        label: '',
        placeholder: '',
        disabled: widget.disabled);

    final childWidget = widget.disabled ? disabledText : dropdownWidget;

    return childWidget;
  }
}
