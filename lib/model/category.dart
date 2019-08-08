class Category {
  final String cate_id;
  final String cate_name;
  Category(
      {this.cate_id,
      this.cate_name});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = new Map<String, dynamic>();
    json['cate_id'] = cate_id;
    json['cate_name'] = cate_name;
    return json;
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
        cate_id: json['cate_id'],
        cate_name: json['cate_name']);
  }
}