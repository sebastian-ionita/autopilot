import 'package:flutter/material.dart';
import 'ABaseDropdown.dart';

class AOption<T> {
  T value;
  String label;

  AOption({
    required this.value,
    required this.label,
  });

  bool operator ==(o) => o is AOption && label == o.label && value == o.value;
}

class ADropdown<TKey> extends StatefulWidget {
  final List<AOption<TKey>> options;
  AOption<TKey>? initialOption;
  final void Function(AOption<TKey>?) onChanged;
  final String hintText;
  bool? disabled;
  final String? Function(AOption<TKey>?)? validator;

  ADropdown({
    required this.options,
    required this.initialOption,
    required this.onChanged,
    required this.hintText,
    this.validator,
    this.disabled,
    Key? key,
  }) : super(key: key);

  @override
  _ADropdownState<TKey> createState() => _ADropdownState<TKey>();
}

class _ADropdownState<TKey> extends State<ADropdown<TKey>> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ABaseDropdown<TKey>(
      options: widget.options,
      initialOption: widget.initialOption,
      disabled: widget.disabled != null ? widget.disabled! : false,
      onChanged: (val) {
        widget.onChanged(val);
      },
      validator: widget.validator,
      textStyle: TextStyle(
        fontFamily: 'AZOSans',
        color: Color(0xFF14181B),
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      hintText: widget.hintText,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF57636C),
        size: 15,
      ),
      fillColor: Colors.white,
      elevation: 2,
    );
  }
}
