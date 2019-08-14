import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'myTextField.dart';

class DateTimePicker extends StatelessWidget {
  const DateTimePicker(
      {Key key,
      this.controller,
      this.labelText,
      this.selectedDate,
      this.selectedTime,
      this.selectDate,
      this.selectTime,
      this.fillColor})
      : super(key: key);

  final String labelText;
  final TextEditingController controller;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> selectDate;
  final ValueChanged<TimeOfDay> selectTime;
  final Color fillColor;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) selectDate(picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) selectTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = TextStyle(fontSize: 16);
    controller.text = new DateFormat('dd-MM-yyyy').format(selectedDate);
    return GestureDetector(
        child: AbsorbPointer(
            child: MyTextField(
              controller: controller,
                label: 'Job Date',
                prefixIcon: Icon(Icons.calendar_today),
                fillColor: fillColor,
                filled: true,
                enabled: false)),
        onTap: () {
          print('tab');
          _selectDate(context);
        });
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.start,
    //   crossAxisAlignment: CrossAxisAlignment.end,
    //   children: <Widget>[
    //     Expanded(
    //       flex: 1,
    //       child: _InputDropdown(
    //         labelText: labelText,
    //         valueText: new DateFormat('dd-MM-yyyy').format(selectedDate),
    //         valueStyle: valueStyle,
    //         onPressed: () {
    //           _selectDate(context);
    //         }
    //       )
    //     )
    //   ],
    // );
  }
}

class _InputDropdown extends StatelessWidget {
  const _InputDropdown({
    Key key,
    this.child,
    this.labelText,
    this.valueText,
    this.valueStyle,
    this.onPressed,
  }) : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
        ),
        baseStyle: valueStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(valueText, style: valueStyle),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.shade700
                  : Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}
