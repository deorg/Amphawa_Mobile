import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget{
  Function(String) onChanged;
  String suffix;

  SearchBar({this.onChanged, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  filled: true,
                  fillColor: Colors.white,
                  //fillColor: Colors.white.withOpacity(0.9),
                  prefixIcon: Icon(Icons.search),
                  suffix: Text(this.suffix),
                  hintText: 'Search',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none)),
              onChanged: (value) {
                onChanged(value);
              },
            )));
  }
}