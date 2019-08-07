import 'package:amphawa/themes/button.dart';
import 'package:amphawa/widgets/dialog/dialog.dart';
import 'package:amphawa/widgets/dialog/dialogListItem.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title = 'Welcome'}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((callback) async {
      List<Widget> listMenu = <Widget>[
        DialogListItem(
          icon: Icons.account_circle,
          text: 'username@gmail.com',
          onPressed: () {
            Navigator.pop(context, 'username@gmail.com');
          },
          color: Colors.green,
        ),
        DialogListItem(
          icon: Icons.account_circle,
          text: 'user02@gmail.com',
          onPressed: () {
            Navigator.pop(context, 'user02@gmail.com');
          },
        ),
        DialogListItem(
          icon: Icons.add_circle,
          text: 'add account',
          onPressed: () {
            Navigator.pop(context, 'add account');
          },
          color: Colors.blue,
        ),
      ];

      Widget content = Container(
        child: Column(
          children: <Widget>[
            Icon(
              Icons.warning,
              size: 48,
              color: Colors.green,
            ),
            SizedBox(height: 10),
            Text('สวัสดีครับ')
          ],
        ),
        height: 80,
      );

      await Alert.dialog(
              context: context,
              message: 'ยินดีต้อนรับ สวัสดีครับ',
              buttons: ['ตกลง', 'ยกเลิก'],
              buttonColor: [Colors.white, Colors.white],
              buttonBorderColor: [
                ButtonColor.info.color,
                ButtonColor.danger.borderColor
              ],
              buttonTextColor: [
                ButtonColor.info.color,
                ButtonColor.danger.color
              ],
              padding: EdgeInsets.only(top: 30, bottom: 15))
          .then((onValue) {
        print(onValue);
      });

      // await Alert.dialogWithUiContent(
      //     context: context,
      //     title: 'ยินดีต้อนรับ',
      //     content: content,
      //     buttons: ['ตกลง', 'ยกเลิก']);

      // await Alert.dialogWithListItem(context: context, title: 'ยินดีต้อนรับ', list: listMenu);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.display1,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _incrementCounter();
            // alert.alertDialog(context);
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ));
  }
}
