import 'package:amphawa/widgets/button/MyButton.dart';
import 'package:flutter/material.dart';

class Alert {
  String message;

  Alert({this.message});

  static Future<String> dialog(
      {BuildContext context,
      String title,
      String message,
      List<String> buttons,
      Color titleColor,
      Color textColor,
      List<Color> buttonColor,
      List<Color> buttonBorderColor,
      List<Color> buttonTextColor,
      String backgroundImage,
      Color backgroundColor = Colors.white,
      EdgeInsetsGeometry padding = const EdgeInsets.all(0)}) async {
    return await showDialog<String>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                contentPadding: EdgeInsets.all(0),
                title: title == null
                    ? null
                    : Center(
                        child: Text(title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: titleColor))),
                content: Container(
                    color: backgroundImage == null ? backgroundColor : null,
                    padding: backgroundImage == null ? EdgeInsets.only(top: 30, bottom: 15) : EdgeInsets.all(0),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(message,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor)),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: buttons == null
                                  ? null
                                  : buttons
                                      .map((name) => new MyButton(
                                            text: name,
                                            color: buttonColor != null ? buttonColor[
                                                buttons.indexOf(name)] : Colors.white,
                                            borderColor: buttonBorderColor != null ? buttonBorderColor[
                                                buttons.indexOf(name)] : Colors.green,
                                            textColor: buttonTextColor != null ? buttonTextColor[buttons.indexOf(name)] : Colors.black,
                                            onpress: () {                                  
                                              Navigator.of(context).pop(name);
                                            },
                                          ))
                                      .toList())
                        ]),
                    decoration: backgroundImage == null
                        ? null
                        : BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  "assets/images/dialog/$backgroundImage"),
                              fit: BoxFit.fill,
                            ),
                          )));
          },
        ) ??
        '';
  }

  static Future<String> dialogWithUiContent(
      {BuildContext context,
      String title,
      Widget content,
      List<String> buttons}) async {
    return await showDialog<String>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: content,
              actions: buttons == null
                  ? null
                  : buttons
                      .map((name) => RaisedButton(
                            child: Text(
                              name,
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              print(name);
                              Navigator.of(context).pop(
                                  name); // Pops the confirmation dialog but not the page.
                            },
                          ))
                      .toList(),
            );
          },
        ) ??
        '';
  }

  static Future<String> dialogWithListItem(
      {BuildContext context, String title, List<Widget> list}) async {
    return await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: list,
            );
          },
        ) ??
        '';
  }

  static Future<bool> snackBar(GlobalKey<ScaffoldState> key, String message) {
    key.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 5)
    )).closed.then((onValue){
      return true;
    });
  }

  static void snackBarByContext(BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 8)));
  }

  static snackBarByContextWithAction(BuildContext context,
      {String message, Function function}) async {
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 60),
        action: SnackBarAction(
            textColor: Colors.white, label: 'ลบ', onPressed: () {})));
  }
}
