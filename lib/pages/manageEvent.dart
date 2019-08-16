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
import 'package:amphawa/widgets/dialog/dialogListItem.dart';
import 'package:amphawa/widgets/form/chipTile.dart';
import 'package:amphawa/widgets/form/dateTimePicker.dart';
import 'package:amphawa/widgets/form/multiSelectChip.dart';
import 'package:amphawa/widgets/form/myTextField.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';

import 'package:http/http.dart';

enum ManageJobAction { ready, readyMore, sent, completed }

class NewEventPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewEventPage();
}

class _NewEventPage extends State<NewEventPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ManageJobAction _action = ManageJobAction.ready;
  String _status = 'completed';
  List<String> _dept = ['ไม่ระบุ'];
  List<String> _sect = ['ไม่ระบุ'];
  List<Category> _rawCate = [];
  List<String> _categories = ['ไม่ระบุ'];
  List<String> _selectedCate = [];
  Color fillColor = Colors.teal[100];
  bool _completed = true;
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
  TextEditingController date_time = new TextEditingController();
  TextEditingController category = new TextEditingController();
  TextEditingController department = new TextEditingController();
  TextEditingController section = new TextEditingController();
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
          leading: new IconButton(
            icon: new Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 36,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('New Job',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Color(0xFF57607B),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.save, size: 36), onPressed: submit)
            // IconButton(icon: Icon(Icons.save), iconSize: 36, onPressed: submit)
          ],
        ),
        backgroundColor: Color(0xFF828DAA),
        body: _buildJobFormUI());
    // body: SingleChildScrollView(child: _buildJobFormUI()));
  }

  Widget _buildJobFormUI() {
    List<Widget> column = [];
    column.add(Container(
        decoration: BoxDecoration(
            color: Color(0xFF57607B),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: GestureDetector(
                // onTap: () => Navigator.pop(context),
                child: Icon(Icons.note_add, color: Colors.white, size: 36)),
          ),
          Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            GestureDetector(
                child: Text(_status,
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                onTap: () {
                  setState(() {
                    _completed = !_completed;
                    if (_completed)
                      _status = 'Completed';
                    else
                      _status = 'In Progress';
                  });
                }),
            SizedBox(width: 8),
            Transform.scale(
                scale: 1.5,
                child: Switch(
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    value: _completed,
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        _completed = value;
                        if (_completed)
                          _status = 'Completed';
                        else
                          _status = 'In Progress';
                      });
                    },
                    inactiveTrackColor: Color(0xFF77BCE1),
                    activeColor: Colors.green)), SizedBox(width: 10)
          ]))
        ]),
        alignment: Alignment.center));
    List<Widget> formContent = [
      SizedBox(height: 5),
      MyTextField(
          controller: job_desc,
          label: 'Description',
          prefixIcon: Icon(Icons.note_add),
          fillColor: fillColor,
          filled: true),
      SizedBox(height: 10.0),
      MyTextField(
          controller: solution,
          label: 'Solution',
          prefixIcon: Icon(Icons.edit),
          fillColor: fillColor,
          maxLines: 3,
          filled: true),
      SizedBox(height: 10.0),
      MyTextField(
          controller: device_no,
          prefixIcon: Icon(Icons.devices),
          fillColor: fillColor,
          label: 'Device No.',
          filled: true),
      SizedBox(height: 10),
      Container(
          decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
          // color: Colors.white,
          child: Column(children: <Widget>[
            Column(children: <Widget>[
              GestureDetector(
                  child: AbsorbPointer(
                      child: MyTextField(
                          controller: category,
                          label: 'Category',
                          prefixIcon: Icon(Icons.category),
                          fillColor: fillColor,
                          filled: true,
                          enabled: false)),
                  onTap: () {
                    Alert.dialogWithListItem(
                            context: context,
                            title: 'Category',
                            list: _categories.map((d) {
                              return DialogListItem(
                                  icon: Icons.category,
                                  text: d,
                                  onPressed: () {
                                    Navigator.pop(context, d);
                                  });
                            }).toList())
                        .then((onValue) {
                      print(onValue);
                      if (onValue != null) {
                        onCateSelected(onValue);
                        category.text = onValue;
                      }
                    });
                  }),
              SizedBox(height: 10),
              GestureDetector(
                  child: AbsorbPointer(
                      child: MyTextField(
                          controller: department,
                          label: 'Department',
                          prefixIcon: Icon(Icons.people),
                          fillColor: fillColor,
                          filled: true,
                          enabled: false)),
                  onTap: () {
                    if (_dept != null) {
                      Alert.dialogWithListItem(
                              context: context,
                              title: 'Department',
                              list: _dept.map((d) {
                                return DialogListItem(
                                    icon: Icons.people,
                                    text: d,
                                    onPressed: () {
                                      Navigator.pop(context, d);
                                    });
                              }).toList())
                          .then((onValue) {
                        print(onValue);
                        if (onValue != null) {
                          onDeptSelected(onValue);
                          department.text = onValue;
                        }
                      });
                    }
                  }),
              SizedBox(height: 10),
              GestureDetector(
                  child: AbsorbPointer(
                      child: MyTextField(
                          controller: section,
                          label: 'Section',
                          prefixIcon: Icon(Icons.perm_identity),
                          fillColor: fillColor,
                          filled: true,
                          enabled: false)),
                  onTap: () {
                    if (_sect.length > 0) {
                      Alert.dialogWithListItem(
                              context: context,
                              title: 'Section',
                              list: _sect.map((d) {
                                return DialogListItem(
                                    icon: Icons.perm_identity,
                                    text: d,
                                    onPressed: () {
                                      Navigator.pop(context, d);
                                    });
                              }).toList())
                          .then((onValue) {
                        print(onValue);
                        if (onValue != null) {
                          onSectSelected(onValue);
                          section.text = onValue;
                        }
                      });
                    }
                  }),
              SizedBox(height: 10),
              DateTimePicker(
                  controller: date_time,
                  fillColor: fillColor,
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
                  })
            ])
          ]))
    ];
    Widget form = Container(
        decoration: BoxDecoration(
            color: Color(0xFFEAEFFB),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15))),
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child:
                SingleChildScrollView(child: Column(children: formContent))));
    // if (_action == ManageJobAction.sent) {
    //   column.add(SizedBox(height: 10, child: LinearProgressIndicator()));
    // }
    column.add(form);
    return Column(children: <Widget>[
      _action == ManageJobAction.sent
          ? SizedBox(height: 10, child: LinearProgressIndicator())
          : SizedBox(height: 0),
      Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Card(
              child: Column(
                  children: column,
                  crossAxisAlignment: CrossAxisAlignment.stretch),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15))))
    ]);
  }
  // Widget _buildJobFormUI() {
  //   List<Widget> column = [];
  //   List<Widget> formContent = [
  //     SizedBox(height: 20),
  //     MyTextField(
  //         controller: job_desc, label: 'Description', icon: Icon(Icons.title)),
  //     SizedBox(height: 20.0),
  //     MyTextField(
  //         controller: solution,
  //         label: 'Solution',
  //         icon: Icon(Icons.note_add),
  //         maxLines: 3),
  //     SizedBox(height: 20.0),
  //     MyTextField(
  //         controller: device_no,
  //         icon: Icon(Icons.devices),
  //         label: 'Device No.'),
  //     SizedBox(height: 20),
  //     MyTextField(
  //         controller: created_by,
  //         icon: Icon(Icons.supervised_user_circle),
  //         label: 'Created by',
  //         enabled: false),
  //     SizedBox(height: 20),
  //     _action == ManageJobAction.ready
  //         ? FlatButton.icon(
  //             icon: const Icon(Icons.add_circle_outline,
  //                 size: 24, color: Colors.blue),
  //             label: const Text('More',
  //                 semanticsLabel: 'More',
  //                 style: TextStyle(fontSize: 20, color: Colors.blue)),
  //             onPressed: () {
  //               setState(() {
  //                 _action = ManageJobAction.readyMore;
  //               });
  //             },
  //           )
  //         : SizedBox(height: 0)
  //   ];
  //   Widget form = Container(
  //       padding: EdgeInsets.symmetric(horizontal: 20),
  //       child: Column(children: formContent));
  //   if (_action == ManageJobAction.sent) {
  //     column.add(SizedBox(height: 10, child: LinearProgressIndicator()));
  //   }
  //   if (_action == ManageJobAction.readyMore) {
  //     // formContent.add(ChipsTile(label: 'ประเภท', children: ));
  //     formContent.add(Row(children: <Widget>[
  //       GestureDetector(
  //           child: Text('Category', style: TextStyle(fontSize: 16)),
  //           onTap: () {
  //             _showCategoriesDialog();
  //           }),
  //       SizedBox(width: 10),
  //       DropdownSimple(
  //           label: 'Category', list: _categories, onSelected: onCateSelected)
  //     ]));
  //     formContent.add(Row(children: <Widget>[
  //       Text('Department', style: TextStyle(fontSize: 16)),
  //       SizedBox(width: 10),
  //       DropdownSimple(label: 'Department', list: _dept, onSelected: onDeptSelected)
  //     ]));
  //     formContent.add(Row(children: <Widget>[
  //       Text('Section', style: TextStyle(fontSize: 16)),
  //       SizedBox(width: 10),
  //       DropdownSimple(
  //           label: 'Section', list: _sect, onSelected: onSectSelected)
  //     ]));
  //     formContent.add(Row(children: <Widget>[SizedBox(height: 10), Text('Job_Date', style: TextStyle(fontSize: 16))],mainAxisAlignment: MainAxisAlignment.start));
  //     formContent.add(Container(
  //         padding: EdgeInsets.symmetric(horizontal: 0),
  //         child: DateTimePicker(
  //           // labelText: 'เหตุการณ์ ณ เวลา',
  //           selectedDate: _fromDate,
  //           selectedTime: _fromTime,
  //           selectDate: (DateTime date) {
  //             setState(() {
  //               _fromDate = date;
  //             });
  //           },
  //           selectTime: (TimeOfDay time) {
  //             setState(() {
  //               _fromTime = time;
  //             });
  //           },
  //         )));
  //     formContent.add(SizedBox(height: 20));
  //   }
  //   column.add(form);
  //   return Column(children: column);
  // }

  void submit() {
    setState(() {
      _action = ManageJobAction.sent;
      List<String> cate_id = [];
      _selectedCate.forEach((f) {
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
          created_by: created_by.text,
          job_status: _completed ? 'completed' : 'progress');
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
    print(res.data);
    if (res.statusCode == 200) {
      if (res.data != 0) {
        setState(() {
          _action = ManageJobAction.ready;
          job_desc.clear();
          solution.clear();
          device_no.clear();
          Alert.snackBar(_scaffoldKey, 'บันทึกข้อมูลสำเร็จ');
        });
      } else {
        setState(() {
          _action = ManageJobAction.ready;
          Alert.snackBar(
              _scaffoldKey, 'พบข้อผิดพลาดจาก Server ไม่สามารถบันทีกข้อมูลได้');
        });
      }
    } else {
      print('http code error');
      print(res.statusCode);
      print(res.statusMessage);
      print(json.decode(res.data));
      setState(() {
        _action = ManageJobAction.ready;
        Alert.snackBar(
            _scaffoldKey, 'พบข้อผิดพลาดจาก Server ไม่สามารถบันทีกข้อมูลได้');
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
            title: Text("Category"),
            content: MultiSelectChip(_categories, onSelectionChanged: (value) {
              _selectedCate = value;
            }),
            actions: <Widget>[
              FlatButton(
                child: Text("Ok"),
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
