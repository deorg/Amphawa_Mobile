import 'package:flutter/material.dart';

class ButtonColor{
  static m_Color primary = new m_Color(Color(0xFFd43f3a), Color(0xFF2e6da4));
  static m_Color success = new m_Color(Color(0xFF5cb85c), Color(0xFF4cae4c));
  static m_Color info = new m_Color(Color(0xFF5bc0de), Color(0xFF46b8da));
  static m_Color warning = new m_Color(Color(0xFFf0ad4e), Color(0xFFeea236));
  static m_Color danger = new m_Color(Color(0xFFd9534f), Color(0xFFd43f3a));
}

class m_Color {
  final Color _color;
  final Color _borderColor;
  m_Color(this._color, this._borderColor);

  Color get color => _color;
  Color get borderColor => _borderColor;
}