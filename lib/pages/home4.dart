import 'package:amphawa/widgets/sidebar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HomePage4 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePage4();
}

class _HomePage4 extends State<HomePage4> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    Center(child: Text('บันทึกเหตุการณ์')),
    Center(child: Text('จัดการบันทคก'))
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.event_note), title: Text('บันทึกเหตุการณ์')),
          BottomNavigationBarItem(
              icon: Icon(Icons.edit, size: 32), title: Text('จัดการบันทึก')),
        ],
      ),
      drawer: SideBar(),
      appBar: AppBar(
        title: Text('Amphawa'),
      ),
      body: _tabs[_currentIndex],
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
