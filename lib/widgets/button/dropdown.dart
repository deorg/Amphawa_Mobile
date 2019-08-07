import 'package:flutter/material.dart';

class DropdownSimple extends StatefulWidget {
  final String label;
  final List<String> list;
  DropdownSimple({this.label, this.list});
  @override
  State<StatefulWidget> createState() => _DropdownSimple(label, list);
}

class _DropdownSimple extends State<DropdownSimple> {
  String _label;
  List<String> _list;
  String _value;
  _DropdownSimple(this._label, this._list);
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
        value: _value == null ? _list.first : _value,
        onChanged: (String newValue) {
          setState(() {
            _value = newValue;
          });
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

    // return ListTile(
    //   title: Text(_label),
    //   trailing: DropdownButton<String>(
    //     value: _value == null ? _list.first : _value,
    //     onChanged: (String newValue) {
    //       setState(() {
    //         _value = newValue;
    //       });
    //     },
    //     items: <String>['One', 'Two', 'Free', 'Four']
    //         .map<DropdownMenuItem<String>>((String value) {
    //       return DropdownMenuItem<String>(
    //         value: value,
    //         child: Text(value),
    //       );
    //     }).toList(),
    //   ),
    // );
  }
}

// class DropdownWithHint extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _DropdownWithHint();
// }

// class _DropdownWithHint extends State<DropdownWithHint> {
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: const Text('Dropdown with a hint:'),
//       trailing: DropdownButton<String>(
//         value: dropdown2Value,
//         hint: const Text('Choose'),
//         onChanged: (String newValue) {
//           setState(() {
//             dropdown2Value = newValue;
//           });
//         },
//         items: <String>['One', 'Two', 'Free', 'Four']
//             .map<DropdownMenuItem<String>>((String value) {
//           return DropdownMenuItem<String>(
//             value: value,
//             child: Text(value),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

// class ScrollableDropdown extends StatefulWidget {}

// class _ScrollableDropdown extends State<ScrollableDropdown> {
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: const Text('Scrollable dropdown:'),
//       trailing: DropdownButton<String>(
//         value: dropdown3Value,
//         onChanged: (String newValue) {
//           setState(() {
//             dropdown3Value = newValue;
//           });
//         },
//         items: <String>[
//           'One',
//           'Two',
//           'Free',
//           'Four',
//           'Can',
//           'I',
//           'Have',
//           'A',
//           'Little',
//           'Bit',
//           'More',
//           'Five',
//           'Six',
//           'Seven',
//           'Eight',
//           'Nine',
//           'Ten',
//         ].map<DropdownMenuItem<String>>((String value) {
//           return DropdownMenuItem<String>(
//             value: value,
//             child: Text(value),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
