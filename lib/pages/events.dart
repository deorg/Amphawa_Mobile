import 'dart:convert';
import 'package:amphawa/model/job.dart';
import 'package:amphawa/pages/editEvent.dart' as edit;
import 'package:amphawa/services/jobs.dart';
import 'package:amphawa/widgets/contact.dart';
import 'package:amphawa/widgets/dialog/dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'manageEvent.dart';

enum JobFetchAction { fetch, blank, error, complete, timeout }

class Events extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Events();
}

class _Events extends State<Events> with TickerProviderStateMixin {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  DateTime datetime = new DateTime.now();
  JobFetchAction action;
  bool _today = false;
  bool _expand = true;
  List<Job> jobs = new List<Job>();
  final refreshKey = GlobalKey<RefreshIndicatorState>();
  SearchBar searchBar;
  // PermissionStatus _permissionStatus;

  @override
  void initState() {
    super.initState();
    // PermissionHandler()
    //     .checkPermissionStatus(PermissionGroup.locationWhenInUse)
    //     .then((status) {
    //   if (status != _permissionStatus) {
    //     _updatePermission(status);
    //   }
    //   if(status != PermissionStatus.granted){
    //     _askForPermission();
    //   }
    // });
    action = JobFetchAction.fetch;
    JobService.fetchJob(
        onFetchFinished: onFetchFinished,
        onfetchTimeout: onFetchTimeout,
        onFetchError: onFetchError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        // appBar: searchBar.build(context),
        appBar: AppBar(
            leading: IconButton(
                icon: _today ? Icon(Icons.view_list) : Icon(Icons.today),
                iconSize: 36,
                onPressed: () {
                  setState(() {
                    _today = !_today;
                  });
                }),
            backgroundColor: Color(0xFF57607B),
            title: Text('Job List',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            actions: <Widget>[
              IconButton(
                  icon: _expand
                      ? Icon(Icons.expand_less)
                      : Icon(Icons.expand_more),
                  iconSize: 36,
                  onPressed: () {
                    setState(() {
                      _expand = !_expand;
                    });
                  })
            ]),
        body: _buildActivity(),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.edit, size: 28),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute<ManageJobAction>(
                    builder: (BuildContext context) => NewEventPage(),
                    fullscreenDialog: true,
                  )).then((ManageJobAction result) {
                action = JobFetchAction.fetch;
                JobService.fetchJob(
                    onFetchFinished: onFetchFinished,
                    onfetchTimeout: onFetchTimeout,
                    onFetchError: onFetchError);
              });
            }));
  }

  Widget _buildActivity() {
    switch (action) {
      case JobFetchAction.fetch:
        return _buildFetchJobUI();
        break;
      case JobFetchAction.complete:
        return _buildFetchCompleteUI();
        break;
      case JobFetchAction.timeout:
        return _buildFetchTimeoutUI();
        break;
      case JobFetchAction.error:
        return _buildFetchErrorUI();
        break;
      case JobFetchAction.blank:
        return _buildNoDataUI();
      default:
        return _buildNoDataUI();
        break;
    }
  }

  Widget _buildFetchJobUI() {
    return Center(
        child: Column(
            children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(
            height: 10,
          ),
          Text(
            'กำลังรับข้อมูลจากเซิฟเวอร์',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )
        ],
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center));
  }

  Widget _buildFetchCompleteUI() {
    List<Job> displayJobs = [];
    if (_today) {
      displayJobs = jobs
          .where((j) =>
              j.job_date.day == DateTime.now().day &&
              j.job_date.month == DateTime.now().month &&
              j.job_date.year == DateTime.now().year)
          .toList();
      print('display job => ${displayJobs.length}');
    } else {
      displayJobs = jobs;
    }
    return RefreshIndicator(
        key: refreshKey,
        onRefresh: () {
          refreshKey.currentState?.show(atTop: false);
          JobService.fetchJob(
              onFetchFinished: onFetchFinished,
              onfetchTimeout: onFetchTimeout,
              onFetchError: onFetchError);
          return Future.value();
        },
        child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10),
            itemCount: displayJobs.length,
            itemBuilder: (context, index) {
              List<String> lines = [];
              if (displayJobs[index].job_desc != null)
                lines.add(displayJobs[index].job_desc);
              if (displayJobs[index].solution != "")
                lines.add("Sol: \t" + displayJobs[index].solution);
              if (displayJobs[index].cate_id != null)
                lines.add("Cate: \t\t" + displayJobs[index].cate_id.join(", "));
              if (displayJobs[index].dept_id != "")
                lines.add("Dept: \t\t" + displayJobs[index].dept_id);
              if (displayJobs[index].sect_id != "")
                lines.add("Sect: \t\t" + displayJobs[index].sect_id);
              if (displayJobs[index].created_by != '')
                lines.add('Writer: ' + displayJobs[index].created_by);
              return Dismissible(
                  key: Key(displayJobs[index].job_id.toString()),
                  background: Container(
                      color: Colors.green[100],
                      child: Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: Align(
                              child: Icon(Icons.check_circle,
                                  color: Colors.green, size: 52),
                              alignment: Alignment.centerLeft))),
                  secondaryBackground: Container(
                      color: Colors.red[100],
                      child: Padding(
                          padding: EdgeInsets.only(right: 30),
                          child: Align(
                              child: Icon(Icons.delete,
                                  color: Colors.red, size: 52),
                              alignment: Alignment.centerRight))),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      setState(() {
                        displayJobs.removeAt(index);
                      });
                    } else {
                      setState(() {
                        displayJobs.removeAt(index);
                      });
                    }
                  },
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      var res = await Alert.dialogWithUiContent(
                          context: context,
                          title: 'Delete job ${displayJobs[index].job_id}',
                          content:
                              Text("Are you sure you want to delete this job?"),
                          buttons: ['Yes', 'No']);
                      if (res == 'Yes')
                        return true;
                      else
                        return false;
                    } else if (direction == DismissDirection.startToEnd) {
                      var res = await Alert.dialogWithUiContent(
                          context: context,
                          title:
                              'Mark job ${displayJobs[index].job_id} to be completed',
                          content: Text("Are you sure you want to finished this job?"),
                          buttons: ['Yes', 'No']);
                      if (res == 'Yes')
                        return true;
                      else
                        return false;
                    } else
                      return false;
                  },
                  // child: IntrinsicHeight(
                  child: AnimatedSize(
                      vsync: this,
                      duration: Duration(milliseconds: 1500),
                      curve: Curves.linearToEaseOut,
                      child: IntrinsicHeight(
                        child: Container(
                            height: _expand
                                ? null
                                : MediaQuery.of(context).size.height * 0.15,
                            child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: InkWell(
                                    child: ListItem(
                                        date: displayJobs[index].job_date,
                                        number: displayJobs.length - index,
                                        // number: index + 1,
                                        icon: Icons.note_add,
                                        lines: lines,
                                        status: displayJobs[index].job_status,
                                        job: displayJobs[index]),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute<ManageJobAction>(
                                            builder: (BuildContext context) =>
                                                edit.EditEventPage(
                                                    displayJobs[index]),
                                            fullscreenDialog: true,
                                          )).then((ManageJobAction result) {
                                        action = JobFetchAction.fetch;
                                        JobService.fetchJob(
                                            onFetchFinished: onFetchFinished,
                                            onfetchTimeout: onFetchTimeout,
                                            onFetchError: onFetchError);
                                      });
                                    }))),
                      )));
            }));
  }

  Widget _buildFetchTimeoutUI() {
    return Center(child: Text('หมดเวลาในการดึงข้อมูล'));
  }

  Widget _buildFetchErrorUI() {
    return Center(child: Text('พบข้อผิดพลาดจากการดึงข้อมูล'));
  }

  Widget _buildNoDataUI() {
    return Center(child: Text('ไม่พบข้อมูล'));
  }

  void onFetchFinished(Response response) {
    if (response.statusCode == 200) {
      List<dynamic> res = json.decode(response.body);
      if (res.length > 0) {
        jobs.clear();
        res.forEach((f) {
          jobs.add(Job.fromJson(f));
        });
        setState(() {
          action = JobFetchAction.complete;
        });
      } else {
        setState(() {
          action = JobFetchAction.blank;
        });
      }
    }
  }

  void onFetchTimeout() {
    print('time out');
    setState(() {
      action = JobFetchAction.timeout;
    });
  }

  void onFetchError(dynamic onError) {
    print(onError);
    setState(() {
      action = JobFetchAction.error;
    });
  }

  // void _updatePermission(PermissionStatus status) {
  //   if (status != _permissionStatus) {
  //     setState(() {
  //       _permissionStatus = status;
  //     });
  //   }
  //   print('status => ');
  //   print(status);
  // }

  // void _askForPermission() {
  //   PermissionHandler().requestPermissions(
  //       [PermissionGroup.locationWhenInUse]).then(_onPermissionRequest);
  // }

  // void _onPermissionRequest(Map<PermissionGroup, PermissionStatus> status) {
  //   final res = status[PermissionGroup.locationWhenInUse];
  //   if (res == PermissionStatus.denied) {
  //     PermissionHandler().openAppSettings();
  //   } else if (res == PermissionStatus.granted){
  //     _updatePermission(res);
  //   }
  //   print('status => $_permissionStatus');
  // }
}
