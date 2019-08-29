import 'dart:io';

class Photo {
  Photo({this.photo, this.url, this.name});

  File photo;
  String url;
  String name;

  String get tag => name; // Assuming that all asset names are unique.

}
