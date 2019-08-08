import 'package:amphawa/model/category.dart';
import 'package:amphawa/model/dept.dart';
import 'package:amphawa/model/job.dart';
import 'package:amphawa/model/sect.dart';
import 'package:amphawa/services/category.dart';
import 'package:amphawa/services/department.dart';
import 'package:amphawa/services/jobs.dart';
import 'package:amphawa/services/section.dart';
import 'package:amphawa/widgets/button/dropdown.dart';
import 'package:amphawa/widgets/dialog/dialog.dart';
import 'package:amphawa/widgets/form/chipTile.dart';
import 'package:amphawa/widgets/form/dateTimePicker.dart';
import 'package:amphawa/widgets/form/multiSelectChip.dart';
import 'package:amphawa/widgets/form/myTextField.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';

import 'package:http/http.dart';

enum ManageJobAction { ready, readyMore, sent, completed }

class ManageEventPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ManageEventPage();
}

class _ManageEventPage extends State<ManageEventPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ManageJobAction _action = ManageJobAction.ready;
  List<String> _dept = ['ไม่ระบุ'];
  List<String> _sect = ['ไม่ระบุ'];
  List<Category> _rawCate = [];
  List<String> _categories = ['ไม่ระบุ'];
  List<String> _selectedCate = [];
  String _selectedDept;
  String _selectedSect;
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
  void initState() {
    // TODO: implement initState
    super.initState();
    DeptService.fetchDept(
        onFetchFinished: onFetchDeptFinished,
        onfetchTimeout: onFetchDeptTimeout,
        onFetchError: onFetchDeptError);
    CategoryService.fetchCategory(
        onFetchFinished: onFetchCateFinished,
        onfetchTimeout: onFetchCateTimeout,
        onFetchError: onFetchCateError);
  }

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

  String _capitalize(String name) {
    assert(name != null && name.isNotEmpty);
    return name.substring(0, 1).toUpperCase() + name.substring(1);
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
      // formContent.add(ChipsTile(label: 'ประเภท', children: ));
      formContent.add(Row(children: <Widget>[
        GestureDetector(
            child: Text('ประเภท', style: TextStyle(fontSize: 16)),
            onTap: () {
              _showCategoriesDialog();
            }),
        SizedBox(width: 10),
        DropdownSimple(
            label: 'ประเภท', list: _categories, onSelected: onCateSelected)
      ]));
      formContent.add(Row(children: <Widget>[
        Text('สาขา', style: TextStyle(fontSize: 16)),
        SizedBox(width: 10),
        DropdownSimple(label: 'สาขา', list: _dept, onSelected: onDeptSelected)
      ]));
      formContent.add(Row(children: <Widget>[
        Text('สายบริการ', style: TextStyle(fontSize: 16)),
        SizedBox(width: 10),
        DropdownSimple(
            label: 'สายบริการ', list: _sect, onSelected: onSectSelected)
      ]));
      formContent.add(Row(children: <Widget>[SizedBox(height: 10), Text('เหตุการณ์ ณ เวลา', style: TextStyle(fontSize: 16))],mainAxisAlignment: MainAxisAlignment.start));
      formContent.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: DateTimePicker(
            // labelText: 'เหตุการณ์ ณ เวลา',
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
      List<String> cate_id = [];
      _selectedCate.forEach((f){
        var res = _rawCate.firstWhere((test) => test.cate_name == f);
        cate_id.add(res.cate_id);
      });
      Job data = new Job(
          job_date: _fromDate,
          job_desc: job_desc.text,
          solution: solution.text,
          cate_id: cate_id,
          dept_id: _selectedDept,
          sect_id: _selectedSect,
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

  void onFetchDeptFinished(Response response) {
    if (response.statusCode == 200) {
      List<dynamic> res = json.decode(response.body);
      if (res.length > 0) {
        _dept.clear();
        _dept.add('ไม่ระบุ');
        res.forEach((f) {
          _dept
              .add('${Dept.fromJson(f).dept_id} ${Dept.fromJson(f).dept_name}');
        });
      }
    }
  }

  void onFetchDeptTimeout() {
    print('dept time out');
  }

  void onFetchDeptError(dynamic onError) {
    print(onError);
  }

  void onFetchSectFinished(Response response) {
    if (response.statusCode == 200) {
      List<dynamic> res = json.decode(response.body);
      if (res.length > 0) {
        _sect.clear();
        _sect.add('ไม่ระบุ');
        res.forEach((f) {
          _sect
              .add('${Sect.fromJson(f).sect_id} ${Sect.fromJson(f).sect_name}');
        });
        setState(() {
          print(_sect.last);
        });
      }
    }
  }

  void onFetchSectTimeout() {
    print('sect time out');
  }

  void onFetchSectError(dynamic onError) {
    print(onError);
  }

  void onFetchCateFinished(Response response) {
    if (response.statusCode == 200) {
      List<dynamic> res = json.decode(response.body);
      if (res.length > 0) {
        _categories.clear();
        _rawCate.clear();
        _categories.add('ไม่ระบุ');
        res.forEach((f) {
          _categories.add(Category.fromJson(f).cate_name.toString());
          _rawCate.add(Category.fromJson(f));
        });
      }
    }
  }

  void onFetchCateTimeout() {
    print('Cate time out');
  }

  void onFetchCateError(dynamic onError) {
    print(onError);
  }

  _showCategoriesDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
            title: Text("เลือกประเภท"),
            content: MultiSelectChip(_categories, onSelectionChanged: (value) {
              _selectedCate = value;
            }),
            actions: <Widget>[
              FlatButton(
                child: Text("ตกลง"),
                onPressed: () {
                  print('selected item');
                  print(_selectedCate);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void onCateSelected(String newValue) {
    _selectedCate.add(newValue);
  }

  void onDeptSelected(String newValue) {
    print('select $newValue');
    if (newValue != 'ไม่ระบุ') {
      _selectedDept = newValue.split(' ').first;
      SectService.fetchSect(
          dept_id: _selectedDept,
          onFetchFinished: onFetchSectFinished,
          onfetchTimeout: onFetchSectTimeout,
          onFetchError: onFetchSectError);
    }
  }

  void onSectSelected(String newValue) {
    _selectedSect = newValue.split(' ').first;
  }
}


