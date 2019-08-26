import 'dart:io';

class Photo {
  Photo({
    this.photo, this.name
  });

  final File photo;
  final String name;

  bool isFavorite;
  String get tag => name; // Assuming that all asset names are unique.

}