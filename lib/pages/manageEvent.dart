import 'package:amphawa/model/job.dart';
import 'package:amphawa/services/jobs.dart';
import 'package:amphawa/widgets/button/dropdown.dart';
import 'package:amphawa/widgets/dialog/dialog.dart';
import 'package:amphawa/widgets/form/dateTimePicker.dart';
import 'package:amphawa/widgets/form/myTextField.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';

enum ManageJobAction { ready, readyMore, sent, completed }

class ManageEventPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ManageEventPage();
}

class _ManageEventPage extends State<ManageEventPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ManageJobAction _action = ManageJobAction.ready;
  List<String> _branch = [
    'ไม่ระบุ',
    'สาขา 06',
    'สาขา 07',
    'สาขา 08',
    'สาขา 09',
    'สาขา 10',
    'สาขา 11',
    'สาขา 12',
    'สาขา 13',
    'สาขา 14'
  ];
  List<String> _path = [
    'ไม่ระบุ',
    '25 ศิริวัฒน์',
    '26 สุชัช',
    '27 วิศรุต',
    '28 ณรงค์ชัย',
    '29 ธน',
    '30 ศุภกิจ',
    '31 ธนโชติ',
    '32 รวิสรา',
    '33 กฤษณพงษ์',
    '34 ไพโรจน์',
    '35 ฐานเอก',
    '36 อริส',
    '37 ธนพล',
    '38 อนุชา'
  ];
  List<String> _categories = ['ไม่ระบุ', 'ซ่อมบำรุง', 'เบิก'];
  DateTime _fromDate = DateTime.now();
  TimeOfDay _fromTime =
      TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);
  TextEditingController job_desc = new TextEditingController();
  TextEditingController solution = new TextEditingController();
  TextEditingController device_no = new TextEditingController();
  TextEditingController created_by =
      new TextEditingController(text: 'Nuttapat Chaiprapun');
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('เพิ่มบันทึก'),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.save), iconSize: 28, onPressed: submit)
          ],
        ),
        body: SingleChildScrollView(child: _buildJobFormUI()));
  }

  Widget _buildJobFormUI() {
    List<Widget> column = [];
    List<Widget> formContent = [
      SizedBox(height: 20),
      MyTextField(
          controller: job_desc, label: 'หัวข้อ', icon: Icon(Icons.title)),
      SizedBox(height: 20.0),
      MyTextField(
          controller: solution,
          label: 'รายละเอียด',
          icon: Icon(Icons.note_add),
          maxLines: 3),
      SizedBox(height: 20.0),
      MyTextField(
          controller: device_no,
          icon: Icon(Icons.devices),
          label: 'หมายเลขอุปกรณ์'),
      SizedBox(height: 20),
      MyTextField(
          controller: created_by,
          icon: Icon(Icons.supervised_user_circle),
          label: 'บันทึกโดย',
          enabled: false),
      SizedBox(height: 20),
      _action == ManageJobAction.ready
          ? GestureDetector(
              onTap: () {
                setState(() {
                  _action = ManageJobAction.readyMore;
                });
              },
              child: Row(children: <Widget>[
                Text('รายละเอียดเพิ่มเติม',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold))
              ], mainAxisAlignment: MainAxisAlignment.start))
          : SizedBox(height: 0)
    ];
    Widget form = Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: formContent));
    if (_action == ManageJobAction.sent) {
      column.add(SizedBox(height: 10, child: LinearProgressIndicator()));
    }
    if (_action == ManageJobAction.readyMore) {
      formContent.add(Row(children: <Widget>[
        Text('ประเภท', style: TextStyle(fontSize: 16)),
        SizedBox(width: 10),
        DropdownSimple(label: 'ประเภท', list: _categories)
      ]));
      formContent.add(
          Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        Row(children: <Widget>[
          Text('สาขา', style: TextStyle(fontSize: 16)),
          SizedBox(width: 10),
          DropdownSimple(label: 'สาขา', list: _branch)
        ]),
        SizedBox(width: 20),
        Row(children: <Widget>[
          Text('สายบริการ', style: TextStyle(fontSize: 16)),
          SizedBox(width: 10),
          DropdownSimple(label: 'สาขา', list: _path)
        ])
      ]));
      formContent.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: DateTimePicker(
            labelText: 'เวลา',
            selectedDate: _fromDate,
            selectedTime: _fromTime,
            selectDate: (DateTime date) {
              setState(() {
                _fromDate = date;
              });
            },
            selectTime: (TimeOfDay time) {
              setState(() {
                _fromTime = time;
              });
            },
          )));
      formContent.add(SizedBox(height: 20));
    }
    column.add(form);
    return Column(children: column);
  }

  void submit() {
    setState(() {
      _action = ManageJobAction.sent;
      Job data = new Job(
          job_date: _fromDate,
          job_desc: job_desc.text,
          solution: solution.text,
          dept_id: '02',
          sect_id: '25',
          device_no: device_no.text,
          created_by: created_by.text);
      print(data.job_desc);
      JobService.createJob(
          job: data,
          onSending: onSending,
          onSent: onSent,
          onSendTimeout: onSendTimeout,
          onSendCatchError: onSendCatchError);
    });
  }

  void onSending(sent, total) {
    var percent = (sent / total) * 100;
    setState(() {
      _progress = percent;
    });
  }

  void onSent(dio.Response res) {
    _progress = 0;
    print(res.statusCode);
    if (res.statusCode == 200) {
      setState(() {
        _action = ManageJobAction.ready;
        job_desc.clear();
        solution.clear();
        device_no.clear();
        created_by.clear();
        Alert.snackBar(_scaffoldKey, 'บันทึกข้อมูลสำเร็จ');
      });
    } else {
      print('http code error');
      print(res.statusCode);
      print(res.statusMessage);
      print(json.decode(res.data));
      setState(() {
        _action = ManageJobAction.ready;
        Alert.snackBar(_scaffoldKey, 'ไม่สามารถบันทีกข้อมูลได้');
      });
    }
  }

  void onSendTimeout() {
    print('time out');
    setState(() {
      _action = ManageJobAction.ready;
      Alert.snackBar(_scaffoldKey, 'หมดเวลาในการส่งข้อมูล');
    });
  }

  void onSendCatchError(dynamic onError) {
    print(onError);
    setState(() {
      _action = ManageJobAction.ready;
      Alert.snackBar(_scaffoldKey, 'พบข้อผิดพลาดในการส่งข้อมูล');
    });
  }
}
