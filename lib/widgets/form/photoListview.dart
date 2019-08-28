import 'dart:io';
import 'package:amphawa/model/image.dart' as img;
import 'package:amphawa/model/photo.dart';
import 'package:amphawa/pages/viewPhoto.dart';
import 'package:amphawa/widgets/dialog/dialog.dart';
import 'package:flutter/material.dart';

class PhotoListItem extends StatelessWidget {
  PhotoListItem(
      {Key key,
      this.photo,
      this.photoNetwork,
      @required this.onTapImage,
      @required this.onTapDelete})
      : super(key: key);

  final Photo photo;
  final img.Image photoNetwork;
  final VoidCallback onTapImage;
  final VoidCallback onTapDelete;

  void showPhoto(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: photo != null ? Text(photo.name) : Text(photoNetwork.img_name),
        ),
        body: SizedBox.expand(
          child: Hero(
            tag: photo != null ? photo.tag : photoNetwork.img_name,
            child: ViewPhoto(photo: photo.photo),
          ),
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        child: Stack(children: <Widget>[
      Container(
          margin: EdgeInsets.only(right: 10),
          child: InkWell(
              child: photo != null ? Image.file(
                photo.photo,
                fit: BoxFit.cover,
              ) : Image.network(photoNetwork.img_url, fit: BoxFit.cover),
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
                    heroTag: photo != null ? photo.tag : photoNetwork.img_name,
                      backgroundColor: Colors.red[300],
                      child: Icon(Icons.close, size: 18),
                      onPressed: onTapDelete))))
    ]));
  }
}
