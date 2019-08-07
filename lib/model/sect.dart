class Sect {
  final String sect_id;
  final String sect_name;
  Sect(
      {this.sect_id,
      this.sect_name});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = new Map<String, dynamic>();
    json['sect_id'] = sect_id;
    json['sect_name'] = sect_name;
    return json;
  }

  factory Sect.fromJson(Map<String, dynamic> json) {
    return Sect(
        sect_id: json['sect_id'],
        sect_name: json['sect_name']);
  }
}
