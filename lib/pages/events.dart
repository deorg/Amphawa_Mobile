import 'dart:convert';
import 'package:amphawa/model/job.dart';
import 'package:amphawa/pages/editEvent.dart' as edit;
import 'package:amphawa/services/jobs.dart';
import 'package:amphawa/widgets/contact.dart';
import 'package:amphawa/widgets/dialog/dialog.dart';
import 'package:amphawa/widgets/searchbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'manageEvent.dart';

enum JobFetchAction { fetch, blank, error, complete, timeout }

class Events extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Events();
}

class _Events extends State<Events> with TickerProviderStateMixin {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  DateTime _datetime = new DateTime.now();
  JobFetchAction _action;
  List<Job> _displayJobs = [];
  bool _today = false;
  bool _progress = false;
  bool _expand = true;
  List<Job> _jobs = new List<Job>();
  String _searchWrd;
  String _hintText;
  int _wrdFound = 0;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  FocusNode searchFocus = new FocusNode();
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
    _action = JobFetchAction.fetch;
    JobService.fetchJob(
        onFetchFinished: onFetchFinished,
        onfetchTimeout: onFetchTimeout,
        onFetchError: onFetchError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            leading: _todayFilterBtn(),
            backgroundColor: Color(0xFF57607B),
            title: Text('Job List',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            actions: _appbarActions()),
        body: _buildActivity(),
        floatingActionButton: _newJobBtn());
  }

  Widget _todayFilterBtn() {
    return IconButton(
        icon: _today ? Icon(Icons.view_list) : Icon(Icons.today),
        iconSize: 36,
        onPressed: () {
          setState(() {
            _today = !_today;
            _displayJobs = _jobs;
            if (_today) {
              _displayJobs = _todayFilter(_displayJobs);
            }
            if (_progress) {
              _displayJobs = _progressFilter(_displayJobs);
            }
            // if (_searchWrd != null && _searchWrd.isNotEmpty) {
            //   _displayJobs = _searchFilter(_displayJobs);
            // }
            _wrdFound = _displayJobs.length;
            _hintText = _today ? '$_wrdFound found' : '';
          });
        });
  }

  List<Widget> _appbarActions() {
    return [
      IconButton(
        icon: _progress
            ? Icon(FontAwesomeIcons.list, color: Colors.white)
            : Icon(FontAwesomeIcons.tasks, color: Colors.white),
        onPressed: () {
          setState(() {
            _progress = !_progress;
            _displayJobs = _jobs;
            if (_today) {
              _displayJobs = _todayFilter(_displayJobs);
            }
            if (_progress) {
              _displayJobs = _progressFilter(_displayJobs);
            }
            // if (_searchWrd != null && _searchWrd.isNotEmpty) {
            //   _displayJobs = _searchFilter(_displayJobs);
            // }
            _wrdFound = _displayJobs.length;
            _hintText = '$_wrdFound found';
            print('word count => $_wrdFound');
          });
        },
      ),
      IconButton(
          icon: _expand ? Icon(Icons.expand_less) : Icon(Icons.expand_more),
          iconSize: 36,
          onPressed: () {
            setState(() {
              _expand = !_expand;
            });
          })
    ];
  }

  Widget _buildActivity() {
    switch (_action) {
      case JobFetchAction.fetch:
        return _buildFetchJobUI();
        break;
      case JobFetchAction.complete:
        return Column(children: <Widget>[
          SearchBar(
              focus: searchFocus,
              onChanged: _onSearchBarChanged,
              suffix: '$_wrdFound found',
              hintText: this._hintText,
              onTap: () {
                this._hintText = '';
              },
              onPress: () {
                print('on search pressed');
                JobService.fetchJobFilter(
                    str: _searchWrd.toLowerCase(),
                    onFetchFinished: onFetchFinished,
                    onFetchTimeout: onFetchTimeout,
                    onFetchError: onFetchError);
              }),
          _buildFetchCompleteUI()
        ]);
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
    _displayJobs = _jobs;
    if (_today) {
      _displayJobs = _todayFilter(_displayJobs);
    }
    if (_progress) {
      _displayJobs = _progressFilter(_displayJobs);
    }
    // if (_searchWrd != null && _searchWrd.isNotEmpty) {
    //   _displayJobs = _searchFilter(_displayJobs);
    // }
    _wrdFound = _displayJobs.length;
    return Expanded(
        child: RefreshIndicator(
            key: _refreshKey,
            semanticsLabel: 'Refresh',
            onRefresh: _onListViewRefresh,
            child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                itemCount: _displayJobs.length,
                itemBuilder: (context, index) {
                  List<String> lines = [];
                  if (_displayJobs[index].job_desc != null)
                    lines.add(_displayJobs[index].job_desc);
                  if (_displayJobs[index].solution != "")
                    lines.add("Sol: \t" + _displayJobs[index].solution);
                  if (_displayJobs[index].cate_id != null)
                    lines.add(
                        "Cate: \t\t" + _displayJobs[index].cate_id.join(", "));
                  if (_displayJobs[index].dept_id != "")
                    lines.add("Dept: \t\t" + _displayJobs[index].dept_id);
                  if (_displayJobs[index].sect_id != "")
                    lines.add("Sect: \t\t" + _displayJobs[index].sect_id);
                  if (_displayJobs[index].created_by != '')
                    lines.add('Writer: ' + _displayJobs[index].created_by);
                  return Dismissible(
                      key: Key(_displayJobs[index].job_id.toString()),
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
                      onDismissed: (direction) =>
                          _onDismissed(direction, index),
                      confirmDismiss: (direction) =>
                          _onConfirmDismiss(direction, index),
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
                                            date: _displayJobs[index].job_date,
                                            number: _displayJobs.length - index,
                                            icon: Icons.note_add,
                                            lines: lines,
                                            status:
                                                _displayJobs[index].job_status,
                                            job: _displayJobs[index]),
                                        onTap: () => _onJobItemTap(index)))),
                          )));
                })));
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

  Widget _newJobBtn() {
    return FloatingActionButton(
        child: Icon(Icons.edit, size: 28),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute<ManageJobAction>(
                builder: (BuildContext context) => NewEventPage(),
                fullscreenDialog: true,
              )).then((ManageJobAction result) {
            _action = JobFetchAction.fetch;
            JobService.fetchJob(
                onFetchFinished: onFetchFinished,
                onfetchTimeout: onFetchTimeout,
                onFetchError: onFetchError);
          });
        });
  }

  List<Job> _todayFilter(List<Job> value) {
    return value
        .where((j) =>
            j.job_date.day == DateTime.now().day &&
            j.job_date.month == DateTime.now().month &&
            j.job_date.year == DateTime.now().year)
        .toList();
  }

  List<Job> _progressFilter(List<Job> value) {
    return value.where((j) => j.job_status != 'completed').toList();
  }

  // List<Job> _searchFilter(List<Job> value) {
  //   return value
  //       .where((j) =>
  //           j.job_desc.toLowerCase().contains(_searchWrd.toLowerCase()) ||
  //           j.solution.toLowerCase().contains(_searchWrd.toLowerCase()) ||
  //           j.dept_id.toLowerCase().contains(_searchWrd.toLowerCase()) ||
  //           j.sect_id.toLowerCase().contains(_searchWrd.toLowerCase()) ||
  //           j.created_by.toLowerCase().contains(_searchWrd.toLowerCase()))
  //       .toList();
  // }
  List<Job> _searchFilter(List<Job> value) {
    print('search word => $_searchWrd');
    JobService.fetchJobFilter(
        str: _searchWrd.toLowerCase(),
        onFetchFinished: (response) {
          if (response.statusCode == 200) {
            List<dynamic> res = json.decode(response.body);
            if (res.length > 0) {
              value.clear();
              res.forEach((f) {
                value.add(Job.fromJson(f));
              });
              return value;
            }
            return null;
          }
        },
        onFetchTimeout: onFetchTimeout,
        onFetchError: onFetchError);
  }

  void _onSearchBarChanged(String value) {
    setState(() {
      _searchWrd = value;
      if (_today) {
        _displayJobs = _todayFilter(_displayJobs);
      }
      if (_progress) {
        _displayJobs = _progressFilter(_displayJobs);
      }
      // if (_searchWrd != null && _searchWrd.isNotEmpty) {
      //   _displayJobs = _searchFilter(_displayJobs);
      // }
      _wrdFound = _displayJobs.length;
    });
  }

  Future _onListViewRefresh() {
    _refreshKey.currentState?.show(atTop: false);
    JobService.fetchJob(
        onFetchFinished: onFetchFinished,
        onfetchTimeout: onFetchTimeout,
        onFetchError: onFetchError);
    return Future.value();
  }

  Future<bool> _onConfirmDismiss(DismissDirection direction, int index) async {
    if (direction == DismissDirection.endToStart) {
      var res = await Alert.dialogWithUiContent(
          context: context,
          title: 'Delete job ${_displayJobs[index].job_id}',
          content: Text("Are you sure you want to delete this job?"),
          buttons: ['Yes', 'No']);
      if (res == 'Yes')
        return true;
      else
        return false;
    } else if (direction == DismissDirection.startToEnd) {
      var res = await Alert.dialogWithUiContent(
          context: context,
          title: 'Mark job ${_displayJobs[index].job_id} to be completed',
          content: Text("Are you sure you want to finished this job?"),
          buttons: ['Yes', 'No']);
      if (res == 'Yes')
        return true;
      else
        return false;
    } else
      return false;
  }

  _onDismissed(DismissDirection direction, int index) {
    if (direction == DismissDirection.endToStart) {
      setState(() {
        _displayJobs.removeAt(index);
      });
    } else {
      setState(() {
        _displayJobs.removeAt(index);
      });
    }
  }

  _onJobItemTap(int index) {
    Navigator.push(
        context,
        MaterialPageRoute<ManageJobAction>(
          builder: (BuildContext context) =>
              edit.EditEventPage(_displayJobs[index]),
          fullscreenDialog: true,
        )).then((ManageJobAction result) {
      _searchWrd = "";
      _action = JobFetchAction.fetch;
      JobService.fetchJob(
          onFetchFinished: onFetchFinished,
          onfetchTimeout: onFetchTimeout,
          onFetchError: onFetchError);
    });
  }

  void onFetchFinished(Response response) {
    if (response.statusCode == 200) {
      List<dynamic> res = json.decode(response.body);
      print('response => $res');
      if (res.length > 0) {
        _jobs.clear();
        res.forEach((f) {
          _jobs.add(Job.fromJson(f));
        });
        setState(() {
          _action = JobFetchAction.complete;
        });
      } else {
        setState(() {
          _action = JobFetchAction.blank;
        });
      }
    }
  }

  void onFetchTimeout() {
    print('time out');
    setState(() {
      _action = JobFetchAction.timeout;
    });
  }

  void onFetchError(dynamic onError) {
    print(onError);
    setState(() {
      _action = JobFetchAction.error;
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
