import 'dart:io';
import 'package:amphawa/model/photo.dart';
import 'package:amphawa/pages/viewPhoto.dart';
import 'package:amphawa/widgets/dialog/dialog.dart';
import 'package:flutter/material.dart';

class PhotoListItem extends StatelessWidget {
  PhotoListItem(
      {Key key,
      this.photo,
      @required this.onTapImage,
      @required this.onTapDelete})
      : super(key: key);

  final Photo photo;
  final VoidCallback onTapImage;
  final VoidCallback onTapDelete;

  @override
  Widget build(BuildContext context) {

    return Container(
        child: Stack(children: <Widget>[
      Container(
          margin: EdgeInsets.only(right: 10),
          child: InkWell(
              child: photo.photo != null ? Image.file(
                photo.photo,
                fit: BoxFit.cover
              ) : Image.network(photo.url, fit: BoxFit.cover),
              onTap: onTapImage),
          width: 120,
          height: 100),
      Container(
          width: 120,
          height: 100,
          child: Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: FloatingActionButton(
                    heroTag: photo.tag,
                      backgroundColor: Colors.red[300],
                      child: Icon(Icons.close, size: 18),
                      onPressed: onTapDelete))))
    ]));
  }
}
