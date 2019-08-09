import 'dart:convert';
import 'package:amphawa/model/job.dart';
import 'package:amphawa/pages/editEvent.dart' as edit;
import 'package:amphawa/services/jobs.dart';
import 'package:amphawa/widgets/contact.dart';
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
            return IntrinsicHeight(
                child: Card(
                  shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
                    child: ListItem(
                        date: jobs[index].job_date,
                        number: index+1,
                        icon: Icons.note_add,
                        onPressed: () {
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
                        },
                        lines: <String>[
                      jobs[index].job_desc,
                      jobs[index].solution,
                    ])),
                );
          },
        ));
    // return ContactCategory(
    //     title: 'ซ่อม',
    //     icon: Icons.build,
    //     children: repairs
    //         .map((j) => ContactItem(
    //             icon: Icons.photo,
    //             onPressed: () {},
    //             lines: <String>[j.job_desc, j.solution, j.created_by]))
    //         .toList());
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
}
