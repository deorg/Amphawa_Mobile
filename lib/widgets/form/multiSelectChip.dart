import 'package:flutter/material.dart';

class MultiSelectChip extends StatefulWidget {
  final List<String> choice;
  final Function(List<String>) onSelectionChanged;
  MultiSelectChip(this.choice, {this.onSelectionChanged});
  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedChoices = List();
  // this function will build and return the choice list
  _buildChoiceList() {
    List<Widget> choices = List();
    widget.choice.remove('ไม่ระบุ');
    widget.choice.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          avatar: selectedChoices.contains(item)
              ? Icon(Icons.check_circle_outline)
              : null,
          label: Text(item),
          selected: selectedChoices.contains(item),
          onSelected: (selected) {
            setState(() {
              selectedChoices.contains(item)
                  ? selectedChoices.remove(item)
                  : selectedChoices.add(item);
              widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}