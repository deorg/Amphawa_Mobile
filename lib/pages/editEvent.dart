import 'dart:convert';
import 'package:amphawa/model/photo.dart';
import 'package:amphawa/pages/viewPhoto.dart';
import 'package:amphawa/widgets/dialog/dialogListItem.dart';
import 'package:amphawa/widgets/form/photoListview.dart';
import 'package:dio/dio.dart' as dio;
import 'package:amphawa/model/category.dart';
import 'package:amphawa/model/dept.dart';
import 'package:amphawa/model/job.dart';
import 'package:amphawa/model/sect.dart';
import 'package:amphawa/services/category.dart';
import 'package:amphawa/services/department.dart';
import 'package:amphawa/services/jobs.dart';
import 'package:amphawa/services/section.dart';
import 'package:amphawa/widgets/dialog/dialog.dart';
import 'package:amphawa/widgets/form/dateTimePicker.dart';
import 'package:amphawa/widgets/form/multiSelectChip.dart';
import 'package:amphawa/widgets/form/myTextField.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

enum ManageJobAction { ready, readyMore, sent, deleted, completed }

class EditEventPage extends StatefulWidget {
  final Job job;
  EditEventPage(this.job);

  @override
  State<StatefulWidget> createState() => _EditEventPage();
}

class _EditEventPage extends State<EditEventPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ManageJobAction _action = ManageJobAction.ready;
  bool _completed = true;
  String _status;
  List<String> _dept = [];
  List<String> _sect = [];
  List<Category> _rawCate = [];
  List<String> _categories = [];
  List<String> _selectedCate = [];
  String _selectedDept;
  String _selectedSect;
  DateTime _fromDate;
  TimeOfDay _fromTime =
      TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);
  TextEditingController job_desc = new TextEditingController();
  TextEditingController solution = new TextEditingController();
  TextEditingController device_no = new TextEditingController();
  TextEditingController created_by = new TextEditingController();
  TextEditingController date_time = new TextEditingController();
  TextEditingController category = new TextEditingController();
  TextEditingController department = new TextEditingController();
  TextEditingController section = new TextEditingController();

  Color fillColor = Colors.teal[100]; //Color(0xFFE5EEED);
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    job_desc.text = widget.job.job_desc;
    solution.text = widget.job.solution;
    device_no.text = widget.job.device_no;
    created_by.text = widget.job.created_by;
    _completed = widget.job.job_status == 'completed' ? true : false;
    _status = _completed == true ? 'Completed' : 'In Progress';
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
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 36,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Edit Job',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Color(0xFF57607B),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.delete, size: 36),
                onPressed: () {
                  delete(widget.job.job_id);
                },
                tooltip: 'Delete'),
            IconButton(
                icon: Icon(Icons.content_copy, size: 30),
                onPressed: () => duplicate()),
            IconButton(
                icon: Icon(Icons.save, size: 36), onPressed: () => overwrite()),
            // IconButton(icon: Icon(Icons.save), iconSize: 36, onPressed: submit)
          ],
        ),
        backgroundColor: Color(0xFF828DAA),
        body: _buildJobFormUI());
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
                child: Icon(Icons.edit, color: Colors.white, size: 36)),
          ),
          // SizedBox(width: 10),
          Expanded(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
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
                        activeColor: Colors.green)),
                SizedBox(width: 10)
              ]))
          // Text('Edit Job',
          //     style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 24,
          //         fontWeight: FontWeight.bold)),
        ]),
        alignment: Alignment.center));
    List<Widget> formContent = [
      Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        // GestureDetector(
        //     child: Text(_status, style: TextStyle(fontSize: 18)),
        //     onTap: () {
        //       setState(() {
        //         _completed = !_completed;
        //         if (_completed)
        //           _status = 'Completed';
        //         else
        //           _status = 'In Progress';
        //       });
        //     }),
        // SizedBox(width: 8),
        // Transform.scale(
        //     scale: 1.5,
        //     child: Switch(
        //         materialTapTargetSize: MaterialTapTargetSize.padded,
        //         value: _completed,
        //         onChanged: (value) {
        //           print(value);
        //           setState(() {
        //             _completed = value;
        //             if (_completed)
        //               _status = 'Completed';
        //             else
        //               _status = 'In Progress';
        //           });
        //         },
        //         inactiveTrackColor: Color(0xFF77BCE1),
        //         activeColor: Colors.green))
      ]),
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
          maxLines: 3,
          fillColor: fillColor,
          filled: true),
      SizedBox(height: 10.0),
      MyTextField(
          controller: device_no,
          prefixIcon: Icon(Icons.devices),
          label: 'Device No.',
          fillColor: fillColor,
          filled: true),
      SizedBox(height: 10),
      MyTextField(
          controller: created_by,
          prefixIcon: Icon(Icons.person_pin),
          fillColor: fillColor,
          filled: true,
          label: 'Created by'),
      SizedBox(height: 15),
      Container(
          decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
          // color: Colors.white,
          child: Column(children: <Widget>[
            Column(children: <Widget>[
              // Row(children: <Widget>[
              //   GestureDetector(
              //       child: SizedBox(
              //           width: 85,
              //           child:
              //               Text('Category', style: TextStyle(fontSize: 16))),
              //       onTap: () {
              //         _showCategoriesDialog();
              //       }),
              //   SizedBox(width: 20),
              //   DropdownSimple(
              //       label: 'Category',
              //       list: _categories,
              //       onSelected: onCateSelected)
              // ]),
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
              // Row(children: <Widget>[
              //   Text('Department', style: TextStyle(fontSize: 16)),
              //   SizedBox(width: 20),
              //   DropdownSimple(
              //       label: 'Department',
              //       list: _dept,
              //       onSelected: onDeptSelected)
              // ]),
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
              // Row(children: <Widget>[
              //   SizedBox(
              //       width: 85,
              //       child: Text('Section', style: TextStyle(fontSize: 16))),
              //   SizedBox(width: 20),
              //   DropdownSimple(
              //       label: 'Section', list: _sect, onSelected: onSectSelected)
              // ]),
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
                  }),
              SizedBox(height: 10),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Photo',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]))),
              SizedBox(height: 5),
              _imagesForm()
            ])
          ]))
    ];
    Widget form = Container(
        decoration: BoxDecoration(
            color: Color(0xFFEAEFFB),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15))),
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
      _action == ManageJobAction.deleted
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

  void submit({bool saveAs = false}) {
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
        dept_id = widget.job.dept_id.split(" ").first;
      } else if (widget.job.dept_id != null && _selectedDept != null) {
        dept_id = _selectedDept;
      } else if (widget.job.dept_id == null && _selectedDept != null) {
        dept_id = _selectedDept;
      } else {
        dept_id = _selectedDept;
      }
      if (widget.job.sect_id != null && _selectedSect == null) {
        sect_id = widget.job.sect_id.split(" ").first;
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
          created_by: created_by.text,
          job_status: _completed ? 'completed' : 'progress');
      print(data.job_id);
      print(_fromDate);
      print(job_desc.text);
      print(solution.text);
      print(cate_id);
      print(dept_id);
      print(sect_id);
      print(device_no.text);
      print(created_by.text);

      if (saveAs) {
        JobService.createJob(
            job: data,
            onSending: onSending,
            onSent: onSent,
            onSendTimeout: onSendTimeout,
            onSendCatchError: onSendCatchError);
      } else {
        JobService.updateJob(
            job: data,
            onSending: onSending,
            onSent: onSent,
            onSendTimeout: onSendTimeout,
            onSendCatchError: onSendCatchError);
      }
    });
  }

  Future delete(int job_id) async {
    var res = await Alert.dialogWithUiContent(
        context: context,
        title: 'Delete job',
        content: Text("Are you sure you want to delete this job?"),
        buttons: ['Yes', 'No']);
    if (res == 'Yes') {
      print(job_id);
      setState(() {
        _action = ManageJobAction.deleted;
        JobService.deleteJob(
            job_id: job_id,
            onDeleted: onDeleted,
            onDeleteTimeout: onDeleteTimeout,
            onDeleteCatchError: onDeleteCatchError);
      });
    }
  }

  Future duplicate() async {
    var res = await Alert.dialogWithUiContent(
        context: context,
        title: 'Duplicate job',
        content: Text("Are you sure you want to duplicate this job?"),
        buttons: ['Yes', 'No']);
    if (res == 'Yes') {
      submit(saveAs: true);
    }
  }

  Future overwrite() async {
    // var res = await Alert.dialogWithUiContent(
    //     context: context,
    //     title: 'Overwrite job',
    //     content: Text("Are you sure you want to Overwrite this job?"),
    //     buttons: ['Yes', 'No']);
    // if (res == 'Yes') {
    submit(saveAs: false);
    // }
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
      if (res.data != 0) {
        setState(() {
          _action = ManageJobAction.ready;
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
        Alert.snackBar(_scaffoldKey, 'ไม่สามารถบันทีก���้อมูลได้');
      });
    }
  }

  void onDeleted(Response res) {
    _progress = 0;
    print(res.statusCode);
    if (res.statusCode == 200) {
      if (res.body != '0') {
        setState(() {
          _action = ManageJobAction.ready;
          Alert.snackBar(_scaffoldKey, 'ลบข้อมูลสำเร็จ');
          Navigator.pop(context);
        });
      } else {
        setState(() {
          _action = ManageJobAction.ready;
          Alert.snackBar(
              _scaffoldKey, 'พบข้อผิดพลาดจาก Server ไม่สามารถลบข้อมูลได้');
        });
      }
    } else {
      print('http code error');
      print(res.statusCode);
      print(json.decode(res.body));
      setState(() {
        _action = ManageJobAction.ready;
        Alert.snackBar(_scaffoldKey, 'ไม่สามารถบันทีกข้อมูลได้');
      });
    }
  }

  void onDeleteTimeout() {
    print('time out');
    setState(() {
      _action = ManageJobAction.ready;
      Alert.snackBar(_scaffoldKey, 'หมดเวลาในการส่งข้อมูล');
    });
  }

  void onDeleteCatchError(dynamic onError) {
    print(onError);
    setState(() {
      _action = ManageJobAction.ready;
      Alert.snackBar(_scaffoldKey, 'พบข้อผิดพลาดในการส่งข้อมูล');
    });
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
        // _dept.add('ไม่ระบุ');
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
        // _sect.add('ไม่ระบุ');
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
        // _categories.add('ไม่ระบุ');
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

  Widget _imagesForm() {
    return DottedBorder(
        padding: EdgeInsets.all(10),
        dashPattern: [5],
        color: Colors.grey[400],
        strokeWidth: 1,
        child: Container(
            width: double.infinity,
            height: 140,
            child: widget.job.images == null
                    ? Center(
                        child: InkWell(
                            child: Text('Add photo',
                                style: TextStyle(fontSize: 24)),
                            onTap: () async {
                              // await ImagePicker.pickImage(
                              //         source: ImageSource.camera)
                              //     .then((value) {
                              //   setState(() {
                              //     _images.add(new Photo(
                              //         photo: value,
                              //         name: value.path.split('/').last));
                              //   });
                              // });
                            }))
                    : Column(children: <Widget>[
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                children: widget.job.images
                                    .map((p) => PhotoListItem(
                                        photoNetwork: p,
                                        onTapImage: () {
                                          // Navigator.push(context,
                                          //     MaterialPageRoute<void>(builder:
                                          //         (BuildContext context) {
                                          //   return Scaffold(
                                          //     backgroundColor: Colors.black,
                                          //     appBar: AppBar(
                                          //       title: Text('View Photo'),
                                          //     ),
                                          //     body: SizedBox.expand(
                                          //       child: Hero(
                                          //         tag: p.img_name,
                                          //         child:
                                          //             ViewPhoto(photo: p.photo),
                                          //       ),
                                          //     ),
                                          //   );
                                          // }));
                                        },
                                        onTapDelete: () async {
                                          // var res = await Alert.dialogWithUiContent(
                                          //     context: context,
                                          //     title: 'Delete Photo',
                                          //     content: Text(
                                          //         "Are you sure you want to delete this photo?"),
                                          //     buttons: ['Yes', 'No']);
                                          // if (res == 'Yes') {
                                          //   p.photo.delete().then((onValue) {
                                          //     setState(() {
                                          //       _images.remove(p);
                                          //     });
                                          //   });
                                          // }
                                        }))
                                    .toList())),
                        SizedBox(height: 10),
                        InkWell(
                            child: Text('Add more photo',
                                style: TextStyle(fontSize: 18)),
                            onTap: () async {
                              // await ImagePicker.pickImage(
                              //         source: ImageSource.camera)
                              //     .then((onValue) {
                              //   setState(() {
                              //     _images.add(new Photo(
                              //         photo: onValue,
                              //         name: onValue.path.split('/').last));
                              //   });
                              // });
                            })
                      ])));
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
    // if (newValue != 'ไม่ระบุ') {
    if (newValue != null) {
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
