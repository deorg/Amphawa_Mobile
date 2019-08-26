import 'dart:io';

import 'package:amphawa/model/category.dart';
import 'package:amphawa/model/dept.dart';
import 'package:amphawa/model/job.dart';
import 'package:amphawa/model/photo.dart';
import 'package:amphawa/model/sect.dart';
import 'package:amphawa/pages/viewPhoto.dart';
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
import 'package:dotted_border/dotted_border.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

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
  TextEditingController created_by = new TextEditingController();
  TextEditingController date_time = new TextEditingController();
  TextEditingController category = new TextEditingController();
  TextEditingController department = new TextEditingController();
  TextEditingController section = new TextEditingController();
  double _progress = 0;
  List<Photo> _images = [];

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
        resizeToAvoidBottomPadding: false,
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
            IconButton(
                icon: Icon(Icons.flash_auto),
                iconSize: 36,
                onPressed: autoSentenseDialog),
            IconButton(icon: Icon(Icons.save, size: 36), onPressed: submit)
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
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child:
                SingleChildScrollView(child: Column(children: formContent))));
    column.add(form);
    return Stack(children: <Widget>[
      Column(children: <Widget>[
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
      ]),
      // Center(
      //     child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      //   CircularProgressIndicator(),
      //   SizedBox(height: 5),
      //   Text('กำลังส่งข้อมูล')
      // ]))
    ]);
  }

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
      Alert.snackBar(_scaffoldKey, 'ห��ดเวลาในการส่งข้อมูล');
    });
  }

  void onSendCatchError(dynamic onError) {
    print(onError);
    setState(() {
      _action = ManageJobAction.ready;
      Alert.snackBar(_scaffoldKey, '���บข้อผิดพลาดในการส่งข้อมูล');
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

  Widget _imagesForm() {
    return DottedBorder(
        padding: EdgeInsets.all(10),
        dashPattern: [5],
        color: Colors.grey[400],
        strokeWidth: 1,
        child: Container(
            width: double.infinity,
            height: 140,
            child: _images.length == 0
                ? Center(
                    child: InkWell(
                        child:
                            Text('Add photo', style: TextStyle(fontSize: 24)),
                        onTap: () {
                          ImagePicker.pickImage(source: ImageSource.camera)
                              .then((value) {
                            print(
                                'image path => ' + value.path.split('/').last);
                            setState(() {
                              _images.add(new Photo(photo: value, name: value.path.split('/').last));
                              print('images length => ${_images.length}');
                            });
                          });
                        }))
                : Column(children: <Widget>[
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            children: _images
                                .map((f) => Container(
                                        child: Stack(children: <Widget>[
                                      Container(
                                          margin: EdgeInsets.only(right: 10),
                                          child: InkWell(
                                              child: Image.file(
                                                f.photo,
                                                fit: BoxFit.cover,
                                              ),
                                              onTap: () {
                                                print('photo index of => ${_images.indexOf(f)}');
                                                print('tag name => temp_photo_${f.tag}');
                                                Navigator.push(context,
                                                    MaterialPageRoute<void>(
                                                        builder: (BuildContext
                                                            context) {
                                                  return Scaffold(
                                                    backgroundColor:
                                                        Colors.black,
                                                    appBar: AppBar(
                                                      title: Text('View Photo'),
                                                    ),
                                                    body: SizedBox.expand(
                                                      child: Hero(
                                                        tag: f.tag,
                                                        child:
                                                            ViewPhoto(photo: f.photo),
                                                      ),
                                                    ),
                                                  );
                                                }));
                                              }),
                                          width: 120,
                                          height: 100),
                                      Container(
                                          width: 120,
                                          height: 100,
                                          child: Align(
                                              alignment: Alignment.topRight,
                                              child: SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: FloatingActionButton(
                                                      backgroundColor:
                                                          Colors.red[300],
                                                      child: Icon(Icons.close,
                                                          size: 18),
                                                      onPressed: () async {
                                                        var res = await Alert.dialogWithUiContent(
                                                            context: context,
                                                            title:
                                                                'Delete Photo',
                                                            content: Text(
                                                                "Are you sure you want to delete this photo?"),
                                                            buttons: [
                                                              'Yes',
                                                              'No'
                                                            ]);
                                                        if (res == 'Yes') {
                                                          setState(() {
                                                            _images.remove(f);
                                                          });
                                                        }
                                                      }))))
                                    ])))
                                .toList())),
                    SizedBox(height: 10),
                    InkWell(
                        child: Text('Add more photo',
                            style: TextStyle(fontSize: 18)),
                        onTap: () {
                          ImagePicker.pickImage(source: ImageSource.camera)
                              .then((onValue) {
                            print('image path => ' +
                                onValue.path.split('/').last);
                            setState(() {
                              _images.add(new Photo(photo: onValue, name: onValue.path.split('/').last));
                              print('images length => ${_images.length}');
                            });
                          });
                        })
                  ])));
  }

  void autoSentenseDialog() {
    List<String> devices = ['Computer', 'Printer', 'GT'];
    TextEditingController summary = new TextEditingController();
    TextEditingController device = new TextEditingController();
    TextEditingController series = new TextEditingController();
    TextEditingController number = new TextEditingController();
    TextEditingController desc = new TextEditingController();
    TextEditingController dept = new TextEditingController();

    TextEditingController deptField = new TextEditingController();
    TextEditingController sectField = new TextEditingController();
    TextEditingController nameField = new TextEditingController();
    List<AutoSentence> options = [
      AutoSentence('อุปกรณ์', Colors.blue[200], Colors.blue, device),
      AutoSentence('รุ่น', Colors.green[200], Colors.green, series),
      AutoSentence('เบอร์', Colors.blueGrey[200], Colors.blueGrey, number),
      AutoSentence('แผนก', Colors.orangeAccent[200], Colors.orangeAccent, dept),
      AutoSentence('ปัญหา', Colors.red[200], Colors.red, desc)
    ]; //['อุปกรณ์', 'รุ่น', 'เบอร์', 'แผนก'];
    List<String> depts = [
      'ข้อมูลกลาง',
      'บัญชี',
      'บริหารเครดิต',
      'MIS',
      'ทีมติดตาม',
      'ส่วนกลาง',
      'บริหาร',
      'MD',
      'บริหารข้อมูลกลาง',
      'ตรวจสอบภายนอก',
      'เร่งรัด',
      'อาคารสถานที่',
      'ทดลองงาน'
    ];

    List<Widget> devicesIcon = [
      InkWell(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Column(children: <Widget>[
                SizedBox(
                    height: 30,
                    width: 30,
                    child: CircleAvatar(
                        child: Icon(Icons.computer, color: Colors.white),
                        backgroundColor: Colors.blue[300])),
                Text('PC', style: TextStyle(fontSize: 10))
              ])),
          onTap: () {
            setState(() {
              device.text = devices[0];
              summary.text =
                  '${device.text} ${series.text} ${series.text} ${desc.text} ${dept.text}';
            });
          }),
      InkWell(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Column(children: <Widget>[
              SizedBox(
                  height: 30,
                  width: 30,
                  child: CircleAvatar(
                      child: Icon(Icons.print, color: Colors.white),
                      backgroundColor: Colors.blue[300])),
              Text('Printer', style: TextStyle(fontSize: 10))
            ])),
        onTap: () {
          setState(() {
            device.text = devices[1];
            summary.text =
                '${device.text} ${series.text} ${series.text} ${desc.text} ${dept.text}';
          });
        },
      ),
      InkWell(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Column(children: <Widget>[
              SizedBox(
                  height: 30,
                  width: 30,
                  child: CircleAvatar(
                      child: Icon(Icons.tablet_android, color: Colors.white),
                      backgroundColor: Colors.blue[300])),
              Text('GT', style: TextStyle(fontSize: 10))
            ])),
        onTap: () {
          setState(() {
            device.text = devices[2];
            summary.text =
                '${device.text} ${series.text} ${series.text} ${desc.text} ${dept.text}';
          });
        },
      )
    ];

    Widget autoSentenceUI =
        Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      TextField(
          controller: summary,
          maxLines: null,
          decoration:
              InputDecoration(labelText: 'รวมเป็น ต.ย.', enabled: false)),
      SizedBox(
        height: 10,
      ),
      Stack(children: <Widget>[
        Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
                width: 70,
                child: TextField(
                    controller: options[0].controller,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                        hintStyle: TextStyle(color: Colors.white),
                        filled: true,
                        hintText: options[0].label,
                        alignLabelWithHint: true,
                        fillColor: options[0].color,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(0))),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: options[0].borderColor, width: 2))),
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)))),
        Align(
            alignment: Alignment.centerRight,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.37,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: devicesIcon))))
      ]),
      Row(children: <Widget>[
        SizedBox(
            width: 70,
            child: TextField(
                controller: options[1].controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                    hintStyle: TextStyle(color: Colors.white),
                    filled: true,
                    hintText: options[1].label,
                    fillColor: options[1].color,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(0))),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: options[1].borderColor, width: 2))),
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold))),
        SizedBox(width: 10),
        Flexible(
            child: TextField(
          onChanged: (value) {
            setState(() {
              series.text = value;
              summary.text =
                  '${device.text} ${series.text} ${number.text} ${desc.text} ${dept.text}';
            });
          },
          decoration: InputDecoration(
              filled: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
        ))
      ]),
      Row(children: <Widget>[
        SizedBox(
            width: 70,
            child: TextField(
                controller: options[2].controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                    hintStyle: TextStyle(color: Colors.white),
                    filled: true,
                    hintText: options[2].label,
                    fillColor: options[2].color,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(0))),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: options[1].borderColor, width: 2))),
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold))),
        SizedBox(width: 10),
        Flexible(
            child: TextField(
          onChanged: (value) {
            setState(() {
              if (value.isNotEmpty)
                number.text = 'No.$value';
              else
                number.clear();
              summary.text =
                  '${device.text} ${series.text} ${number.text} ${desc.text} ${dept.text}';
            });
          },
          decoration: InputDecoration(
              filled: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 10)),
        ))
      ]),
      Stack(children: <Widget>[
        Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
                width: 70,
                child: TextField(
                    controller: options[3].controller,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                        hintStyle: TextStyle(color: Colors.white),
                        filled: true,
                        hintText: options[3].label,
                        fillColor: options[3].color,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(Radius.circular(0))),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: options[3].borderColor, width: 2))),
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)))),
        Align(
            alignment: Alignment.centerRight,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.37,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: depts
                            .map((d) => Padding(
                                padding: EdgeInsets.only(right: 3),
                                child: SizedBox(
                                    width: 50,
                                    child: FlatButton(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 0),
                                        child: Text(d,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center),
                                        onPressed: () {
                                          dept.text = d;
                                          summary.text =
                                              '${device.text} ${series.text} ${number.text} ${desc.text} ${dept.text}';
                                        },
                                        color: Colors.orange[300]))))
                            .toList()))))
      ]),
      Row(children: <Widget>[
        SizedBox(
            width: 70,
            child: TextField(
                controller: options[4].controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                    hintStyle: TextStyle(color: Colors.white),
                    filled: true,
                    hintText: options[4].label,
                    fillColor: options[4].color,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(0))),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: options[4].borderColor, width: 2))),
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold))),
        SizedBox(width: 10),
        Flexible(
            child: TextField(
                onChanged: (value) {
                  setState(() {
                    desc.text = value;
                    summary.text =
                        '${device.text} ${series.text} ${number.text} ${desc.text} ${dept.text}';
                  });
                },
                decoration: InputDecoration(
                    filled: true,
                    focusColor: Colors.red,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10))))
      ])

      // Row(children: optionsTextField),
      // SizedBox(height: 5),
      // TextField(
      //     controller: job_desc,
      //     onChanged: (value) {
      //       setState(() {
      //         summary.text =
      //             '${device.text} ${series.text}, No.${number.text}, ${job_desc.text}, ${dept.text}';
      //       });
      //     },
      //     decoration: InputDecoration(labelText: 'ปัญหา', filled: true),
      //     style: TextStyle(fontSize: 12)),
      // SizedBox(height: 5),
      // Row(children: optionsColumn),
    ]);

    Alert.autoSentenseDialog(
        context: context,
        title: 'Assist',
        content: SingleChildScrollView(child: autoSentenceUI),
        // height: MediaQuery.of(context).size.height * 0.45),
        buttons: ['ตกลง']).then((onValue) {
      if (onValue == 'ตกลง') {
        print(summary.text);
        setState(() {
          job_desc.text = summary.text;
        });
      }
    });
  }
}

class AutoSentence {
  String label;
  Color color;
  Color borderColor;
  TextEditingController controller;
  AutoSentence(this.label, this.color, this.borderColor, this.controller);
}
