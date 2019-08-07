import 'dart:async';
import 'package:amphawa/pages/manageEvent.dart';
import 'package:amphawa/services/jobs.dart';
import 'package:amphawa/widgets/contact.dart';
import 'package:amphawa/model/job.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart';

enum AppBarBehavior { normal, pinned, floating, snapping }
enum JobFetchAction { fetch, blank, error, complete, timeout }

class HomePage5 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePage5State();
}

class _HomePage5State extends State<HomePage5> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  DateTime datetime = new DateTime.now();
  // final double _appBarHeight = 256.0;
  JobFetchAction action;
  double _progress = 0;
  List<Job> repairs = new List<Job>();

  AppBarBehavior _appBarBehavior = AppBarBehavior.pinned;

  @override
  void initState() {
    super.initState();
    action = JobFetchAction.fetch;
    Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        datetime = DateTime.now();
      });
    });
    JobService.fetchJob(onFetchFinished: onFetchFinished, onfetchTimeout: onFetchTimeout, onFetchError: onFetchError);
  }

  @override
  Widget build(BuildContext context) {
    final double _appBarHeight = MediaQuery.of(context).size.height * 0.3;

    // final List<Job> withdraws = job.withdraw;
    // final List<Job> stocks = job.stock;
    // final List<Job> adjusts = job.adjust;

    return Scaffold(
        key: _scaffoldKey,
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.edit, size: 28),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute<ManageJobAction>(
                    builder: (BuildContext context) => ManageEventPage(),
                    fullscreenDialog: true,
                  )).then((ManageJobAction result) {
                  action = JobFetchAction.fetch;
                  // fetchJob();
                  JobService.fetchJob(onFetchFinished: onFetchFinished, onfetchTimeout: onFetchTimeout, onFetchError: onFetchError);
                
              });
            }),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: _appBarHeight,
              pinned: _appBarBehavior == AppBarBehavior.pinned,
              floating: _appBarBehavior == AppBarBehavior.floating ||
                  _appBarBehavior == AppBarBehavior.snapping,
              snap: _appBarBehavior == AppBarBehavior.snapping,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  tooltip: 'Edit',
                  onPressed: () {
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text("Editing isn't supported in this screen."),
                    ));
                  },
                ),
                PopupMenuButton<AppBarBehavior>(
                  onSelected: (AppBarBehavior value) {
                    // setState(() {
                    //   _appBarBehavior = value;
                    // });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuItem<AppBarBehavior>>[
                    PopupMenuItem<AppBarBehavior>(
                      value: AppBarBehavior.normal,
                      child: Text('App bar scrolls away'),
                    ),
                    PopupMenuItem<AppBarBehavior>(
                      value: AppBarBehavior.pinned,
                      child: Text('App bar stays put'),
                    ),
                    PopupMenuItem<AppBarBehavior>(
                      value: AppBarBehavior.floating,
                      child: Text('App bar floats'),
                    ),
                    PopupMenuItem<AppBarBehavior>(
                      value: AppBarBehavior.snapping,
                      child: Text('App bar snaps'),
                    ),
                  ],
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('ยินดีต้อนรับ',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Row(children: <Widget>[
                        Text(
                            DateFormat('EEEE, dd MMM yyyy')
                                .format(DateTime.now()),
                            style: TextStyle(fontSize: 12)),
                        SizedBox(width: 30),
                        Text(DateFormat('hh:mm:ss').format(datetime),
                            style: TextStyle(fontSize: 12))
                      ])
                    ]),
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                        decoration: new BoxDecoration(
                      color: Color(0xff7c94b6),
                      image: new DecorationImage(
                        fit: BoxFit.cover,
                        colorFilter: new ColorFilter.mode(
                            Colors.black.withOpacity(0.4), BlendMode.dstATop),
                        image: AssetImage('assets/images/profile/company.jpg'),
                      ),
                    )),
                    // Image.asset(
                    //   'assets/images/profile/company.jpg',
                    //   fit: BoxFit.cover,
                    //   height: _appBarHeight,
                    // ),
                    // This gradient ensures that the toolbar icons are distinct
                    // against the background image.
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, -1.0),
                          end: Alignment(0.0, -0.4),
                          colors: <Color>[Color(0x60000000), Color(0x00000000)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate(<Widget>[
              AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle.dark,
                  child: Center(child: _buildActivity()))
            ]))
          ],
        ));
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
    }
  }

  Widget _buildFetchJobUI() {
    return Column(
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
        mainAxisAlignment: MainAxisAlignment.center);
  }

  Widget _buildFetchCompleteUI() {
    return ContactCategory(
        title: 'ซ่อม',
        icon: Icons.build,
        children: repairs
            .map((j) => ContactItem(
                icon: Icons.photo,
                onPressed: () {},
                lines: <String>[j.job_desc, j.solution, j.created_by]))
            .toList());
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

  void onFetchFinished(Response response){
    if (response.statusCode == 200) {
        List<dynamic> res = json.decode(response.body);
        if (res.length > 0) {
          repairs.clear();
          res.forEach((f) {
            repairs.add(Job.fromJson(f));
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
  void onFetchTimeout(){
    print('time out');
      setState(() {
        action = JobFetchAction.timeout;
      });
  }
  void onFetchError(dynamic onError){
    print(onError);
      setState(() {
        action = JobFetchAction.error;
      });
  }
}


