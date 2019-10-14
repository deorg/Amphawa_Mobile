import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget{
  Function(String) onChanged;
  Function onTap;
  Function onPress;
  String suffix;
  String hintText;
  FocusNode focus;

  SearchBar({this.focus, this.onChanged, this.suffix, this.hintText, this.onTap, this.onPress});

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
              focusNode: focus,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  filled: true,
                  fillColor: Colors.white,
                  //fillColor: Colors.white.withOpacity(0.9),
                  prefixIcon: IconButton(icon: Icon(Icons.search),onPressed: (){
                    onPress();
                  }),
                  //suffix: Text(this.suffix),
                  suffixText: this.suffix,
                  hintText: this.hintText,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none)),
              onChanged: onChanged,
              onTap: onTap
            )));
  }
}