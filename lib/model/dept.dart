class Dept {
  final String dept_id;
  final String dept_name;
  Dept(
      {this.dept_id,
      this.dept_name});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = new Map<String, dynamic>();
    json['dept_id'] = dept_id;
    json['dept_name'] = dept_name;
    return json;
  }

  factory Dept.fromJson(Map<String, dynamic> json) {
    return Dept(
        dept_id: json['dept_id'],
        dept_name: json['dept_name']);
  }
}
