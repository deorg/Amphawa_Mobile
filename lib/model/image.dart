class Image{
  int job_id;
  String img_name;
  String img_url;
  Image({this.job_id, this.img_name, this.img_url});

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
        job_id: int.parse(json['job_id'].toString()),
        img_name: json['img_name'].toString(),
        img_url: json['img_url'].toString());
  }
}