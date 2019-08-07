import 'package:amphawa/widgets/sidebar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HomePage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          drawer: SideBar(),
          appBar: AppBar(
            title: Text('Amphawa'),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                    icon: Icon(Icons.event_note),
                    child: Text('บันทึกเหตุการณ์')),
                Tab(icon: Icon(Icons.edit, size: 32), text: 'จัดการบันทึก'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Center(child: Text('บันทึกเหตุการณ์')),
              Center(child: Text('จัดการบันทึก'))
            ],
          ),
        ));
  }
}
