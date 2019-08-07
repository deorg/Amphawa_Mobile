import 'package:flutter/material.dart';

class Login extends StatelessWidget{
  final String title;
  Login({this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: Center(
        child: Text('Login page')
      )
    );
  }
}