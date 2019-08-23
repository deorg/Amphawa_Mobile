import 'package:amphawa/helper/thaiDate.dart';
import 'package:amphawa/model/job.dart';
import 'package:amphawa/themes/circleAvartar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

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
  ListItem(
      {Key key,
      this.date,
      this.icon,
      this.lines,
      this.status,
      this.tooltip,
      this.onPressed,
      this.number,
      this.job})
      // : assert(lines.length > 1),
      : super(key: key);

  final DateTime date;
  final IconData icon;
  final List<String> lines;
  final String status;
  final String tooltip;
  final VoidCallback onPressed;
  final int number;
  final Job job;
  Color _completed = Colors.lightGreen[200];
  Color _inProgress = Colors.lightBlueAccent[100];
  // List colors = [Colors.lightGreen[200], Colors.red[200], Colors.amber[200]];

  @override
  Widget build(BuildContext context) {
    // final List<Widget> columnChildren = lines
    //     .sublist(0, lines.length)
    //     // .sublist(0, lines.length - 1)
    //     .map<Widget>((String line) => Text(line,
    //         style: lines.indexOf(line) == 0
    //             ? TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
    //             : null))
    //     .toList();

    // columnChildren.add(Text(lines.last, style: themeData.textTheme.caption));

    final List<Widget> columnChildren = [];
    if (job.job_desc != null) {
      columnChildren.add(Row(children: <Widget>[
        Expanded(child: Text(job.job_desc,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))
      ]));
    }
    if (job.solution != "") {
      columnChildren.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text('Soln:'),
        SizedBox(width: 20),
        Expanded(child: Text(job.solution))
      ]));
    }
    if (job.cate_id != null) {
      columnChildren.add(Row(children: <Widget>[
        Text('Cate:'),
        SizedBox(width: 10),
        Text('\t\t' + job.cate_id.join(", "))
      ]));
    }
    if (job.dept_id != "") {
      columnChildren.add(Row(children: <Widget>[
        Text('Dept:'),
        SizedBox(width: 10),
        Text('\t\t' + job.dept_id)
      ]));
    }
    if (job.sect_id != "") {
      columnChildren.add(Row(children: <Widget>[
        Text('Sect:'),
        SizedBox(width: 10),
        Text('\t\t' + job.sect_id)
      ]));
    }
    if (job.created_by != '') {
      columnChildren.add(Row(children: <Widget>[
        Text('Writer:'),
        SizedBox(width: 10),
        Text(job.created_by)
      ]));
    }

    final List<Widget> rowChildren = <Widget>[
      Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(children: <Widget>[
            Text(
                '${date.day}-${ThaiDate(date).thaiShortMonth}-${ThaiDate(date).thaiShortYear}',
                style: TextStyle(fontSize: 12)),
            Text('${ThaiDate(date).thaiShortDay}',
                style: TextStyle(fontSize: 12)),
            SizedBox(
              height: 5,
            ),
            Expanded(
                child: Center(
                    child: CircleAvatar(
              backgroundColor: ColorDays[date.weekday],
              child: Text(number.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            )))
          ])),
      SizedBox(width: 10),
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: GestureDetector(
              onTap: onPressed,
              child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: columnChildren,
                  ))),
        ),
      ),
      Container(
          alignment: Alignment.bottomCenter,
          width: 15,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(15),
                  topRight: Radius.circular(15)),
              color: status == 'completed' ? _completed : _inProgress))
    ];

    return MergeSemantics(
        child: Padding(
            padding: EdgeInsets.only(left: 10, top: 0, bottom: 0, right: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: rowChildren,
            )));
  }
}
