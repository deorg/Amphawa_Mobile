import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onpress;
  MyButton(
      {this.text,
      this.color,
      this.textColor,
      this.borderColor = Colors.black,
      this.onpress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onpress,
        child: DecoratedBox(
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: color),
          child: Theme(
            data: Theme.of(context).copyWith(
                buttonTheme: ButtonTheme.of(context).copyWith(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)),
            child: GestureDetector(
                onTap: onpress,
                child: OutlineButton(
                    onPressed: onpress,
                    borderSide: BorderSide(color: borderColor, width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Text(text, style: TextStyle(color: textColor)))),
          ),
        ));
  }
}
