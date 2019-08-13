import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  int maxLines = 1;
  final Widget icon;
  final Widget prefixIcon;
  final Widget suffixIcon;
  final bool filled;
  final InputBorder border;
  bool enabled = true;
  TextStyle textStyle = TextStyle(fontSize: 16);
  MyTextField(
      {this.controller,
      this.label,
      this.maxLines,
      this.icon,
      this.prefixIcon,
      this.suffixIcon,
      this.filled,
      this.border,
      this.textStyle, this.enabled});

  @override
  Widget build(BuildContext context) {
    return TextField(
          controller: this.controller,
          enabled: this.enabled,
          decoration: InputDecoration(
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            filled: this.filled,
            icon: this.icon,
            suffixIcon: this.suffixIcon,
            prefixIcon: this.prefixIcon,
            labelText: this.label,
            border: this.border
          ),
          maxLines: this.maxLines,
          textAlignVertical: TextAlignVertical.bottom,
          style: this.textStyle);
  }
}
