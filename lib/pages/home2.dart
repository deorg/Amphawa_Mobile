import 'package:amphawa/themes/button.dart';
import 'package:amphawa/widgets/button/MyButton.dart';
import 'package:amphawa/widgets/dialog/dialog.dart';
import 'package:flutter/material.dart';

class HomePage2 extends StatelessWidget {
  TextEditingController brh_id = new TextEditingController();
  TextEditingController path_no = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
          child: Column(
            children: <Widget>[
              txtBrhId(context),
              SizedBox(height: 10),
              txtPathNo(context),
              SizedBox(height: 20),
              btnSubmit(context)
            ],
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          )),
    );
  }

  Widget txtBrhId(BuildContext context) {
    return TextField(
      controller: brh_id,
      decoration: InputDecoration(
          labelText: 'สาขา', filled: true, hintText: 'สาขาที่มี'),
      onChanged: (result) => validBranch(result, context),
    );
  }

  Widget txtPathNo(BuildContext context) {
    return TextField(
      controller: path_no,
      decoration: InputDecoration(labelText: 'สายบริการ', filled: true),
    );
  }

  Widget btnSubmit(BuildContext context) {
    return MyButton(
        borderColor: Colors.green,
        textColor: Colors.teal,
        text: 'ตกลง',
        onpress: () => onSubmit(context));
  }

  void onSubmit(BuildContext context) {
    Alert.dialog(
        context: context,
        title: 'ยินดีต้อนรับ',
        message: 'สาขา ${brh_id.text}, สายบริการ ${path_no.text}',
        buttons: ['ตกลง']);
  }

  void validBranch(String result, BuildContext context) {
    if (result.isNotEmpty) {
      if (int.parse(result) > 14) {
        Alert.dialog(
            context: context,
            message: 'ชื่อสาขาไม่ถูกต้อง!',
            buttons: ['ตกลง'],
            textColor: Colors.red);
      }
    }
  }
}
