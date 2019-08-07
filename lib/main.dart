import 'package:amphawa/pages/events.dart';
import 'package:amphawa/pages/home2.dart';
import 'package:amphawa/pages/home3.dart';
import 'package:amphawa/pages/home4.dart';
import 'package:amphawa/pages/home5.dart';
import 'package:amphawa/pages/manageEvent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'pages/login.dart';
import 'themes/themes.dart' as theme;
import 'pages/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // debugPaintSizeEnabled = true;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme.lightBlue(),
      // home: HomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/': (BuildContext context) => Events(),
        '/login': (BuildContext context) => Login(title: 'Login page'),
        '/manageJob': (BuildContext context) => ManageEventPage()
      },
    );
  }
}
