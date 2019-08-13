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

class _Events extends State<Events> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  DateTime datetime = new DateTime.now();
  JobFetchAction action;
  List<Job> jobs = new List<Job>();
  final refreshKey = GlobalKey<RefreshIndicatorState>();
  SearchBar searchBar;

  @override
  void initState() {
    super.initState();
    action = JobFetchAction.fetch;
    JobService.fetchJob(
        onFetchFinished: onFetchFinished,
        onfetchTimeout: onFetchTimeout,
        onFetchError: onFetchError);
  }

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Text('Job List'),
        actions: [searchBar.getSearchAction(context)]);
  }

  void onSubmitted(String value) {
    setState(() => _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text('You wrote $value!'))));
  }

  _Events() {
    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: onSubmitted,
        onClosed: () {
          print("closed");
        });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        // appBar: searchBar.build(context),
        appBar: AppBar(
          title: Text('Job List'),
          centerTitle: true,
        ),
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
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            List<String> lines = [];
            if (jobs[index].job_desc != null) lines.add(jobs[index].job_desc);
            if (jobs[index].solution != "")
              lines.add("Solution: " + jobs[index].solution);
            if (jobs[index].cate_id != null)
              lines.add("Category: " + jobs[index].cate_id.join(", "));
            if (jobs[index].dept_id != "")
              lines.add("Department: " + jobs[index].dept_id);
            if (jobs[index].sect_id != "")
              lines.add("Section: " + jobs[index].sect_id);

            return Dismissible(
                key: Key(jobs[index].job_id.toString()),
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
                            child:
                                Icon(Icons.delete, color: Colors.red, size: 52),
                            alignment: Alignment.centerRight))),
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    setState(() {
                      jobs.removeAt(index);
                    });
                  } else {
                    setState(() {
                      jobs.removeAt(index);
                    });
                  }
                },
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    var res = await Alert.dialogWithUiContent(
                        context: context,
                        title: 'Delete job ${jobs[index].job_id}',
                        content:
                            Text("Are you sure you want to delete this job?"),
                        buttons: ['Yes', 'No']);
                    if(res == 'Yes')
                      return true;
                      else return false;
                  }
                  else if(direction == DismissDirection.startToEnd){
                    var res = await Alert.dialogWithUiContent(
                        context: context,
                        title: 'Mark to finished job ${jobs[index].job_id}',
                        content:
                            Text("Are you sure you want to finished this job?"),
                        buttons: ['Yes', 'No']);
                    if(res == 'Yes')
                      return true;
                      else return false;
                  }
                  else
                   return false;
                },
                child: IntrinsicHeight(
                  child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: InkWell(
                          child: ListItem(
                              date: jobs[index].job_date,
                              number: index + 1,
                              icon: Icons.note_add,
                              lines: lines),
                          onTap: () {
                            print('press on ${jobs[index].job_id}');
                            Navigator.push(
                                context,
                                MaterialPageRoute<ManageJobAction>(
                                  builder: (BuildContext context) =>
                                      edit.EditEventPage(jobs[index]),
                                  fullscreenDialog: true,
                                )).then((ManageJobAction result) {
                              action = JobFetchAction.fetch;
                              JobService.fetchJob(
                                  onFetchFinished: onFetchFinished,
                                  onfetchTimeout: onFetchTimeout,
                                  onFetchError: onFetchError);
                            });
                          })),
                ));
          }
        ));
  }

  Widget _buildFetchTimeoutUI() {
    return Center(child: Text('หมดเวลาในการดึงข้อมูล'));
  }

  Widget _buildFetchErrorUI() {
    return Center(child: Text('พบข้อผิดพลาดจากการดึงข้อมูล'));
  }

  Widget _buildNoDataUI() {
    return Center(child: Text('ไม่พบข้อมู���'));
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
}
