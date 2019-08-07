import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContactCategory extends StatelessWidget {
  ContactCategory(
      {Key key,
      @required this.icon,
      @required this.children,
      @required this.title})
      : super(key: key);

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // final ThemeData themeData = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      // decoration: BoxDecoration(
      //     border: Border(bottom: BorderSide(color: themeData.dividerColor))),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.subhead,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Container(
                    //   padding: EdgeInsets.symmetric(vertical: 10),
                    //   width: 72.0,
                    //   child: Icon(icon, color: themeData.primaryColor),
                    // ),
                    Expanded(child: Column(children: children)),
                  ],
                )
              ]),
        ),
      ),
    );
  }
}

class ContactItem extends StatelessWidget {
  ContactItem({Key key, this.icon, this.lines, this.tooltip, this.onPressed})
      : assert(lines.length > 1),
        super(key: key);

  final IconData icon;
  final List<String> lines;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final List<Widget> columnChildren = lines
        .sublist(0, lines.length - 1)
        .map<Widget>((String line) => Text(line))
        .toList();
    columnChildren.add(Text(lines.last, style: themeData.textTheme.caption));
    columnChildren.add(Divider());

    final List<Widget> rowChildren = <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columnChildren,
        ),
      ),
    ];
    rowChildren.add(
        Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Text(DateFormat('dd MMM yyyy').format(DateTime.now()),
          style: TextStyle(fontSize: 12))
    ]));

    return MergeSemantics(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: rowChildren,
        ),
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  ListItem({Key key, this.icon, this.lines, this.tooltip, this.onPressed})
      : assert(lines.length > 1),
        super(key: key);

  final IconData icon;
  final List<String> lines;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final List<Widget> columnChildren = lines
        .sublist(0, lines.length - 1)
        .map<Widget>((String line) => Text(line,
            style: lines.indexOf(line) == 0
                ? TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                : null))
        .toList();
    columnChildren.add(Text(lines.last, style: themeData.textTheme.caption));

    final List<Widget> rowChildren = <Widget>[
      // Icon(Icons.note_add, size: 36, color: Colors.blueGrey),
      CircleAvatar(backgroundColor: Colors.blueGrey, child: Icon(Icons.note_add, size: 32, color: Colors.white,)),
      SizedBox(width: 15),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columnChildren,
        ),
      ),
    ];
    // rowChildren.add(
    //     Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
    //   Text(DateFormat('dd MMM yyyy').format(DateTime.now()),
    //       style: TextStyle(fontSize: 12))
    // ]));

    return MergeSemantics(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: rowChildren,
        ),
      ),
    );
  }
}
