import 'package:flutter/material.dart';

ThemeData lightGreen() => ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.green,
    accentColor: Colors.green,
    buttonColor: Colors.teal,
    fontFamily: 'Sarabun');

ThemeData darkGreen() => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.green,
    accentColor: Colors.grey,
    buttonColor: Colors.teal,
    fontFamily: 'Kodchasan');

    ThemeData lightBlue() => ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    accentColor: Colors.blue,
    buttonColor: Colors.blueGrey,
    fontFamily: 'Sarabun');

    ThemeData light() => ThemeData(
    primaryColor: Colors.white,
    accentColor: Colors.orange,
    hintColor: Colors.white,
    dividerColor: Colors.white,
    buttonColor: Colors.white,
    scaffoldBackgroundColor: Colors.black,
    canvasColor: Colors.black,
  );
