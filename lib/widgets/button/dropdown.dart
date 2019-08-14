import 'package:flutter/material.dart';

class DropdownSimple extends StatefulWidget {
  final String label;
  final List<String> list;
  final Function onSelected;

  DropdownSimple({this.label, this.list, this.onSelected});
  @override
  State<StatefulWidget> createState() => _DropdownSimple(label, list, onSelected);
}

class _DropdownSimple extends State<DropdownSimple> {
  String _label;
  List<String> _list;
  String _value;
  Function _onSelected;
  _DropdownSimple(this._label, this._list, this._onSelected);
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      iconSize: 0,
      icon: null,
        value: _value == null ? _list.first : _value,
        onChanged: (String newValue) {
          setState(() {
            _value = newValue;
          });
          _onSelected(newValue);
        },
        items: _list
          .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(fontSize: 14)),
            );
          })
          .toList(),
      );
  }
}

