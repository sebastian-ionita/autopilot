import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:smart_boat/ui/base/ATextField/validators.dart';
import 'package:smart_boat/ui/base/theme.dart';
import '../utils/controls_utils.dart';
import 'KeyboardOverlay.dart';

class ATextField extends StatefulWidget {
  final ATextFieldTypes type;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final List<TextInputFormatter>? formatters;
  final String label;
  final bool? disabled;
  final String placeholder;
  final String? prefixText;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final bool? autoFocus;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final Future<void> Function(TimeOfDay?)? onTimeChanged;
  final Future<void> Function(DateTime?)? onDateChanged;

  final AutovalidateMode? autovalidateMode;
  final bool? allUppercase;
  final bool? firstUppercase;
  final bool? firstEveryWordUppercase;
  const ATextField(
      {Key? key,
      required this.type,
      required this.controller,
      required this.label,
      required this.placeholder,
      this.onTimeChanged,
      this.onDateChanged,
      this.textInputAction,
      this.validator,
      this.autoFocus,
      this.prefixText,
      this.onChanged,
      this.formatters,
      this.keyboardType,
      this.initialDate,
      this.initialTime,
      this.allUppercase,
      this.firstUppercase,
      this.disabled,
      this.firstEveryWordUppercase,
      this.autovalidateMode})
      : super(key: key);

  @override
  _ATextFieldState createState() => _ATextFieldState();
}

class _ATextFieldState extends State<ATextField> {
  bool _isHidden = true;
  bool _maskedContent = false;
  bool _userFocused = false;

  FocusNode focusNode = FocusNode();
  final fieldKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();

    if (widget.type == ATextFieldTypes.sensitive) {
      _maskedContent = true;
    }

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        //validate when losing focus
        fieldKey.currentState!.validate();
        //submit field when losing focus
      } else {}
    });

    if (widget.type == ATextFieldTypes.number ||
        widget.type == ATextFieldTypes.phone ||
        widget.type == ATextFieldTypes.multiLineText ||
        widget.type == ATextFieldTypes.text ||
        widget.type == ATextFieldTypes.email ||
        widget.type == ATextFieldTypes.birthDate ||
        widget.type == ATextFieldTypes.date ||
        widget.type == ATextFieldTypes.time ||
        widget.type == ATextFieldTypes.address ||
        widget.type == ATextFieldTypes.password ||
        widget.type == ATextFieldTypes.search) {
      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          _userFocused = true;
          KeyboardOverlay.showOverlay(context, doneAction);
        } else {
          KeyboardOverlay.removeOverlay();
          if (_userFocused) {
            onFieldSubmitted(widget.controller.text);
            _userFocused = false;
          }
        }
      });
    }

    if (widget.initialDate != null) {
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      widget.controller.text = formatter.format(widget.initialDate!);
    }
  }

  Future<void> doneAction() async {
    //onFieldSubmitted(widget.controller.text);
  }

  @override
  void dispose() {
    //widget.controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  IconButton? getSufixIcon(ATextFieldTypes type) {
    switch (type) {
      case ATextFieldTypes.password:
        return IconButton(
            onPressed: () {
              setState(() {
                _isHidden = !_isHidden;
              });
            },
            icon: Icon(_isHidden ? Icons.visibility_off : Icons.visibility));
      case ATextFieldTypes.sensitive:
        return IconButton(
            onPressed: () {
              setState(() {
                _maskedContent = !_maskedContent;
              });
            },
            icon: Icon(
                !_maskedContent ? Icons.visibility_off : Icons.visibility));
      case ATextFieldTypes.search:
        return IconButton(
            onPressed: () {
              widget.controller.clear();
              focusNode.unfocus();
              if (widget.onChanged != null) widget.onChanged!('');
            },
            icon: const Icon(Icons.close));
      case ATextFieldTypes.birthDate:
      case ATextFieldTypes.date:
      case ATextFieldTypes.dateTime:
        return IconButton(
            onPressed: () async {
              await showDatePickerModal();
            },
            icon: const Icon(Icons.calendar_month));
      case ATextFieldTypes.time:
        return IconButton(
            onPressed: () async {
              //await showTimePickerModal();
              //prefill with the current time
              var currentDate = DateTime.now().toLocal();
              var currentTime =
                  TimeOfDay(hour: currentDate.hour, minute: currentDate.minute);
              if (widget.onTimeChanged != null) {
                widget.onTimeChanged!(currentTime);
              }
            },
            icon: const FaIcon(
              FontAwesomeIcons.clock,
            ));
      case ATextFieldTypes.text:
      case ATextFieldTypes.number:
      case ATextFieldTypes.email:
      case ATextFieldTypes.address:
      case ATextFieldTypes.phone:
      case ATextFieldTypes.multiLineText:
        return null;
    }
  }

  IconButton? getPrefixIcon(ATextFieldTypes type) {
    switch (type) {
      case ATextFieldTypes.search:
        return IconButton(onPressed: () {}, icon: const Icon(Icons.search));
      case ATextFieldTypes.email:
      case ATextFieldTypes.password:
      case ATextFieldTypes.text:
      case ATextFieldTypes.birthDate:
      case ATextFieldTypes.date:
      case ATextFieldTypes.time:
      case ATextFieldTypes.dateTime:
      case ATextFieldTypes.number:
      case ATextFieldTypes.address:
      case ATextFieldTypes.phone:
      case ATextFieldTypes.sensitive:
      case ATextFieldTypes.multiLineText:
        return null;
    }
  }

  TextInputType? getKeyboardType(ATextFieldTypes type) {
    if (widget.keyboardType != null) return widget.keyboardType;
    switch (type) {
      case ATextFieldTypes.password:
        return TextInputType.visiblePassword;
      case ATextFieldTypes.email:
        return TextInputType.emailAddress;
      case ATextFieldTypes.text:
      case ATextFieldTypes.search:
        return TextInputType.text;
      case ATextFieldTypes.birthDate:
      case ATextFieldTypes.date:
      case ATextFieldTypes.dateTime:
      case ATextFieldTypes.time:
        return TextInputType.number;
      case ATextFieldTypes.number:
      case ATextFieldTypes.phone:
        return TextInputType.number;
      case ATextFieldTypes.multiLineText:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  List<String> getAutoFillFints(ATextFieldTypes type) {
    switch (type) {
      case ATextFieldTypes.password:
        return [AutofillHints.password];
      case ATextFieldTypes.email:
        return [AutofillHints.email];
      case ATextFieldTypes.birthDate:
        return [AutofillHints.birthdayDay];
      case ATextFieldTypes.phone:
        return [AutofillHints.telephoneNumber];
      case ATextFieldTypes.phone:
        return [AutofillHints.telephoneNumber];
      case ATextFieldTypes.address:
        return [AutofillHints.fullStreetAddress];
      case ATextFieldTypes.number:
      case ATextFieldTypes.text:
      case ATextFieldTypes.search:
      case ATextFieldTypes.time:
      case ATextFieldTypes.date:
      case ATextFieldTypes.dateTime:
      default:
        return [];
    }
  }

  List<TextInputFormatter> getTextFormatters() {
    List<TextInputFormatter> formatters = [];
    if (widget.allUppercase != null && widget.allUppercase!) {
      formatters.add(UpperCaseTextFormatter());
    }
    if (widget.firstUppercase != null && widget.firstUppercase!) {
      formatters.add(UpperCaseFirstLetterTextFormatter());
    }
    if (widget.firstEveryWordUppercase != null &&
        widget.firstEveryWordUppercase!) {
      formatters.add(UpperCaseFirstLetterEveryWordTextFormatter());
    }
    if (widget.type == ATextFieldTypes.number) {
      formatters
          .add(FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')));
    }
    if (widget.type == ATextFieldTypes.birthDate ||
        widget.type == ATextFieldTypes.date) {
      var maskFormatter = MaskTextInputFormatter(
          initialText: widget.controller.text,
          mask: '##/##/####',
          type: MaskAutoCompletionType.lazy);
      formatters.add(maskFormatter);
    }
    if (widget.type == ATextFieldTypes.time) {
      var maskFormatter = new MaskTextInputFormatter(
          initialText: widget.controller.text,
          mask: '##:##',
          type: MaskAutoCompletionType.lazy);
      formatters.add(maskFormatter);
    }

    if (widget.formatters != null && widget.formatters!.length > 0) {
      formatters.addAll(widget.formatters!);
    }
    return formatters;
  }

  Paint? getMaskedForeground() {
    if (widget.type == ATextFieldTypes.sensitive && _maskedContent) {
      return Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.grey
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    } else {
      return null;
    }
  }

  bool showCursor() {
    return true;
    /* widget.type != ATextFieldTypes.birthDate &&
        widget.type != ATextFieldTypes.date &&
        widget.type != ATextFieldTypes.dateTime &&
        widget.type != ATextFieldTypes.time; */
  }

  bool readonly() {
    //do not show keyboard
    return (widget.disabled != null && widget.disabled!) ||
        widget.type == ATextFieldTypes.birthDate ||
        widget.type == ATextFieldTypes.dateTime ||
        widget.type == ATextFieldTypes.date ||
        widget.type == ATextFieldTypes.time;
  }

  Future<void> showDatePickerModal() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFD5A2FC), // header background color
                onPrimary: Colors.black, // header text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black, // button text color
                ),
              ),
            ),
            child: child!,
          );
        },
        initialEntryMode: DatePickerEntryMode.calendar,
        locale: const Locale('en', 'IN'),
        fieldHintText: 'dd/mm/yyyy',
        initialDate: widget.initialDate != null
            ? widget.initialDate!
            : DateTime.now().toLocal(),
        firstDate:
            DateTime.now().toLocal().add(const Duration(days: -(100 * 365))),
        lastDate: widget.type == ATextFieldTypes.birthDate
            ? DateTime.now().toLocal()
            : DateTime.now().toLocal().add(const Duration(days: 365)));
    if (picked != null) {
      if (widget.onDateChanged != null) {
        await widget.onDateChanged!(picked);
        if (fieldKey.currentState!.hasError) {
          fieldKey.currentState!.validate();
        }
        focusNode.nextFocus();
      }
    }
  }

  Future<void> showTimePickerModal() async {
    final TimeOfDay? picked = await showTimePicker(
        initialTime: widget.initialTime ?? TimeOfDay.now(), context: context);
    if (picked != null) {
      if (widget.onTimeChanged != null) {
        await widget.onTimeChanged!(picked);
        if (fieldKey.currentState!.hasError) {
          fieldKey.currentState!.validate();
        }
        focusNode.unfocus();
      }
    }
  }

  bool timeOfDayEquals(TimeOfDay a, TimeOfDay b) {
    if (a.hour == b.hour && a.minute == b.minute && a.period == b.period) {
      return true;
    }
    return false;
  }

  bool dateTimeEquals(DateTime a, DateTime b) {
    if (a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute) return true;
    return false;
  }

  void onFieldSubmitted(String value) {
    switch (widget.type) {
      case ATextFieldTypes.birthDate:
      case ATextFieldTypes.date:
        {
          //create a date from value and submit on selected date
          DateTime? date;
          final components = value.split("/");
          if (Validators.dateTimeValidator(value) == null &&
              components.length == 3) {
            final day = int.tryParse(components[0]);
            final month = int.tryParse(components[1]);
            final year = int.tryParse(components[2]);
            if (day != null && month != null && year != null) {
              date = DateTime(year, month, day);
            }
          }
          //check if date changed
          if (widget.initialDate != null) {
            //initial date was not null, check if new date is different
            if (date != null && !dateTimeEquals(widget.initialDate!, date)) {
              if (widget.onDateChanged != null) widget.onDateChanged!(date);
            }
          } else {
            //initial date null, save curent time
            if (date != null) {
              if (widget.onDateChanged != null) {
                widget.onDateChanged!(date);
              }
            }
          }

          break;
        }
      case ATextFieldTypes.time:
        {
          //create a timeofday time from selected value, and submit
          TimeOfDay? time;
          final components = value.split(":");
          if (Validators.timeValidator(value) == null &&
              components.length == 2) {
            final hour = int.tryParse(components[0]);
            final minute = int.tryParse(components[1]);
            if (hour != null && minute != null) {
              time = TimeOfDay(hour: hour, minute: minute);
            }
          }
          //check if time changed
          if (widget.initialTime != null) {
            //initial time was not null, check if new time is different
            if (time != null && !timeOfDayEquals(widget.initialTime!, time)) {
              if (widget.onTimeChanged != null) widget.onTimeChanged!(time);
            }
          } else {
            //initial time null, save curent time
            if (time != null) {
              if (widget.onTimeChanged != null) {
                widget.onTimeChanged!(time);
              }
            }
          }
          break;
        }
      default:
        break;
    }
  }

  void onTap() {
    switch (widget.type) {
      case ATextFieldTypes.date:
      case ATextFieldTypes.birthDate:
      case ATextFieldTypes.time:
        {
          widget.controller.selection = TextSelection.fromPosition(
            const TextPosition(offset: 0),
          );
          break;
        }
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
      child: TextFormField(
        key: fieldKey,
        focusNode: focusNode,
        onTap: onTap,
        textInputAction: widget.textInputAction,
        autofocus: widget.autoFocus ?? false,
        scrollPadding: const EdgeInsets.only(bottom: 80),
        enabled: widget.disabled == null ? true : !widget.disabled!,
        showCursor: showCursor(),
        controller: widget.controller,
        inputFormatters: getTextFormatters(),
        maxLines: widget.type == ATextFieldTypes.multiLineText ? null : 1,
        validator: widget.validator,
        onFieldSubmitted: onFieldSubmitted,
        onChanged: widget.onChanged,
        autovalidateMode: widget.autovalidateMode,
        autofillHints: getAutoFillFints(widget.type),
        obscureText:
            widget.type == ATextFieldTypes.password ? _isHidden : false,
        decoration: InputDecoration(
          hintText: widget.placeholder,
          suffixIcon: getSufixIcon(widget.type),
          prefixIcon: getPrefixIcon(widget.type),
          prefixText: widget.prefixText,
          labelText: widget.label,
          errorMaxLines: 5,
          errorStyle: const TextStyle(
            fontFamily: 'Outfit',
            color: Color.fromARGB(255, 203, 104, 99),
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: SmartBoatTheme.of(context).primaryTextColor,
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
          floatingLabelBehavior: widget.type == ATextFieldTypes.email ||
                  widget.type == ATextFieldTypes.password
              ? FloatingLabelBehavior.always
              : widget.type == ATextFieldTypes.search
                  ? FloatingLabelBehavior.never
                  : FloatingLabelBehavior.auto,
          labelStyle: TextStyle(
            fontFamily: 'Outfit',
            color: SmartBoatTheme.of(context).primaryTextColor,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          hintStyle: const TextStyle(
            fontFamily: 'AZOSans',
            color: Color(0xFF57636C),
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: SmartBoatTheme.of(context).secondaryTextColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFFF1F4F8),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: SmartBoatTheme.of(context).primaryTextColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: widget.disabled != null && widget.disabled!
              ? const Color.fromARGB(255, 248, 245, 245)
              : Colors.transparent,
          contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 20),
        ),
        style: TextStyle(
          fontFamily: 'AZOSans',
          color: widget.type == ATextFieldTypes.sensitive
              ? null
              : SmartBoatTheme.of(context).primaryTextColor,
          fontSize: 14,
          foreground: getMaskedForeground(),
          fontWeight: FontWeight.normal,
        ),
        keyboardType: getKeyboardType(widget.type),
      ),
    );
  }
}

enum ATextFieldTypes {
  text,
  multiLineText,
  password,
  email,
  search,
  birthDate,
  date,
  dateTime,
  time,
  number,
  phone,
  address,
  sensitive
}
