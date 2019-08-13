import 'dart:convert';
import 'package:dio/dio.dart' as dio;
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
import 'package:amphawa/widgets/form/dateTimePicker.dart';
import 'package:amphawa/widgets/form/multiSelectChip.dart';
import 'package:amphawa/widgets/form/myTextField.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

enum ManageJobAction { ready, readyMore, sent, completed }

class EditEventPage extends StatefulWidget {
  final Job job;
  EditEventPage(this.job);

  @override
  State<StatefulWidget> createState() => _EditEventPage();
}

class _EditEventPage extends State<EditEventPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ManageJobAction _action = ManageJobAction.ready;
  List<String> _status = ['ACTIVE', 'FINISHED', 'FAIL'];
  List<String> _dept = ['ไม่ระบุ'];
  List<String> _sect = ['ไม่ระบุ'];
  List<Category> _rawCate = [];
  List<String> _categories = ['ไม่ระบุ'];
  List<String> _selectedCate = [];
  String _selectedDept;
  String _selectedSect;
  DateTime _fromDate;
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
    super.initState();
    job_desc.text = widget.job.job_desc;
    solution.text = widget.job.solution;
    device_no.text = widget.job.device_no;
    created_by.text = widget.job.created_by;
    _fromDate = widget.job.job_date;

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
        // appBar: AppBar(
        //   title: Text('Edit Job ${widget.job.job_id}'),
        //   actions: <Widget>[
        //     IconButton(icon: Icon(Icons.save), iconSize: 28, onPressed: submit)
        //   ],
        // ),
        backgroundColor: Color(0xFF828DAA),
        body: Center(child: SingleChildScrollView(child: _buildJobFormUI())));
  }

  String _capitalize(String name) {
    assert(name != null && name.isNotEmpty);
    return name.substring(0, 1).toUpperCase() + name.substring(1);
  }

  Widget _buildJobFormUI() {
    List<Widget> column = [];
    column.add(Container(
        decoration: BoxDecoration(
            color: Color(0xFF57607B),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Stack(children: <Widget>[
          Center(
              child: Text('Edit Job',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold))),
          Padding(
              padding: EdgeInsets.only(right: 10),
              child: Align(
                  child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child:
                          Icon(Icons.backspace, color: Colors.white, size: 28)),
                  alignment: Alignment.centerRight))
        ]),
        alignment: Alignment.center));
    List<Widget> formContent = [
      SizedBox(height: 10),
      MyTextField(
          controller: job_desc,
          label: 'Description',
          prefixIcon: Icon(Icons.note_add),
          border: OutlineInputBorder(),
          filled: true),
      SizedBox(height: 10.0),
      MyTextField(
          controller: solution,
          label: 'Solution',
          prefixIcon: Icon(Icons.edit),
          border: OutlineInputBorder(),
          maxLines: 3,
          filled: true),
      SizedBox(height: 10.0),
      MyTextField(
          controller: device_no,
          prefixIcon: Icon(Icons.devices),
          label: 'Device No.',
          border: OutlineInputBorder(),
          filled: true),
      SizedBox(height: 10),
      Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          // color: Colors.white,
          child: Column(children: <Widget>[
            Column(children: <Widget>[
              Row(children: <Widget>[
                SizedBox(
                    width: 85,
                    child: Text('Status', style: TextStyle(fontSize: 16))),
                SizedBox(width: 20),
                DropdownSimple(
                    label: 'Department',
                    list: _status,
                    onSelected: onDeptSelected)
              ]),
              Row(children: <Widget>[
                GestureDetector(
                    child: SizedBox(
                        width: 85,
                        child:
                            Text('Category', style: TextStyle(fontSize: 16))),
                    onTap: () {
                      _showCategoriesDialog();
                    }),
                SizedBox(width: 20),
                DropdownSimple(
                    label: 'Category',
                    list: _categories,
                    onSelected: onCateSelected)
              ]),
              Row(children: <Widget>[
                Text('Department', style: TextStyle(fontSize: 16)),
                SizedBox(width: 20),
                DropdownSimple(
                    label: 'Department',
                    list: _dept,
                    onSelected: onDeptSelected)
              ]),
              Row(children: <Widget>[
                SizedBox(
                    width: 85,
                    child: Text('Section', style: TextStyle(fontSize: 16))),
                SizedBox(width: 20),
                DropdownSimple(
                    label: 'Section', list: _sect, onSelected: onSectSelected)
              ]),
              Row(children: <Widget>[
                SizedBox(height: 10),
                Text('Job Date', style: TextStyle(fontSize: 16)),
              ], mainAxisAlignment: MainAxisAlignment.start),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: DateTimePicker(
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
                  )),
              SizedBox(height: 10),
              Center(
                  child: RaisedButton(
                      child:
                          Text('Save', style: TextStyle(color: Colors.white, fontSize: 20)),
                      onPressed: submit,
                      color: Colors.green[400]))
            ])
          ]))
      // _action == ManageJobAction.ready
      //     ? FlatButton.icon(
      //         icon: const Icon(Icons.add_circle_outline,
      //             size: 24, color: Colors.blue),
      //         label: const Text('More',
      //             semanticsLabel: 'More',
      //             style: TextStyle(fontSize: 20, color: Colors.blue)),
      //         onPressed: () {
      //           setState(() {
      //             _action = ManageJobAction.readyMore;
      //           });
      //         },
      //       )
      //     : SizedBox(height: 0)
    ];
    Widget form = Container(
        decoration: BoxDecoration(
            color: Color(0xFFEAEFFB), borderRadius: BorderRadius.circular(15)),
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Column(children: formContent));
    if (_action == ManageJobAction.sent) {
      column.add(SizedBox(height: 10, child: LinearProgressIndicator()));
    }
    // if (_action == ManageJobAction.readyMore) {
    //   formContent.add(Row(children: <Widget>[
    //     GestureDetector(
    //         child: Text('Category', style: TextStyle(fontSize: 16)),
    //         onTap: () {
    //           _showCategoriesDialog();
    //         }),
    //     SizedBox(width: 10),
    //     DropdownSimple(
    //         label: 'Category', list: _categories, onSelected: onCateSelected)
    //   ]));
    //   formContent.add(Row(children: <Widget>[
    //     Text('Department', style: TextStyle(fontSize: 16)),
    //     SizedBox(width: 10),
    //     DropdownSimple(
    //         label: 'Department', list: _dept, onSelected: onDeptSelected)
    //   ]));
    //   formContent.add(Row(children: <Widget>[
    //     Text('Section', style: TextStyle(fontSize: 16)),
    //     SizedBox(width: 10),
    //     DropdownSimple(
    //         label: 'Section', list: _sect, onSelected: onSectSelected)
    //   ]));
    //   formContent.add(Row(children: <Widget>[
    //     SizedBox(height: 10),
    //     Text('Job Date', style: TextStyle(fontSize: 16))
    //   ], mainAxisAlignment: MainAxisAlignment.start));
    //   formContent.add(Container(
    //       padding: EdgeInsets.symmetric(horizontal: 0),
    //       child: DateTimePicker(
    //         selectedDate: _fromDate,
    //         selectedTime: _fromTime,
    //         selectDate: (DateTime date) {
    //           setState(() {
    //             _fromDate = date;
    //           });
    //         },
    //         selectTime: (TimeOfDay time) {
    //           setState(() {
    //             _fromTime = time;
    //           });
    //         },
    //       )));
    //   formContent.add(SizedBox(height: 20));
    // }
    column.add(form);
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Card(
            child: Column(
                children: column,
                crossAxisAlignment: CrossAxisAlignment.stretch),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))));
  }

  void submit() {
    String dept_id;
    String sect_id;
    setState(() {
      _action = ManageJobAction.sent;
      List<String> cate_id = [];
      _selectedCate.forEach((f) {
        var res = _rawCate.firstWhere((test) => test.cate_name == f);
        cate_id.add(res.cate_id);
      });
      if (widget.job.dept_id != null && _selectedDept == null) {
        dept_id = widget.job.dept_id;
      } else if (widget.job.dept_id != null && _selectedDept != null) {
        dept_id = _selectedDept;
      } else if (widget.job.dept_id == null && _selectedDept != null) {
        dept_id = _selectedDept;
      } else {
        dept_id = _selectedDept;
      }
      if (widget.job.sect_id != null && _selectedSect == null) {
        sect_id = widget.job.sect_id;
      } else if (widget.job.sect_id != null && _selectedSect != null) {
        sect_id = _selectedSect;
      } else if (widget.job.sect_id == null && _selectedSect != null) {
        sect_id = _selectedSect;
      } else {
        sect_id = _selectedSect;
      }

      Job data = new Job(
          job_id: widget.job.job_id,
          job_date: _fromDate,
          job_desc: job_desc.text,
          solution: solution.text,
          cate_id: cate_id,
          dept_id: dept_id,
          sect_id: sect_id,
          device_no: device_no.text,
          created_by: created_by.text);
      print(data.job_id);
      JobService.updateJob(
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
