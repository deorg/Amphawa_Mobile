import 'dart:convert' as convert;

class Job {
  final int job_id;
  final DateTime job_date;
  final String job_desc;
  final String solution;
  final String dept_id;
  final String sect_id;
  final String device_no;
  final List<String> cate_id;
  final String created_by;
  final DateTime created_time;
  final String job_status;
  Job(
      {this.job_id,
      this.job_date,
      this.job_desc,
      this.solution,
      this.dept_id,
      this.sect_id,
      this.device_no,
      this.cate_id,
      this.created_by,
      this.created_time,
      this.job_status});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = new Map<String, dynamic>();
    json['job_id'] = job_id.toString();
    json['job_date'] = job_date.toString();
    json['job_desc'] = job_desc;
    json['solution'] = solution;
    json['dept_id'] = dept_id;
    json['sect_id'] = sect_id;
    json['device_no'] = device_no;
    json['cate_id'] = cate_id;
    json['created_by'] = created_by;
    json['job_status'] = job_status;
    return json;
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
        job_id: int.parse(json['job_id'].toString()),
        job_date: DateTime.parse(json['job_date']),
        job_desc: json['job_desc'],
        solution: json['solution'],
        dept_id: json['dept_id'],
        sect_id: json['sect_id'],
        device_no: json['device_no'],
        cate_id: convertCate_id(json['cate_id']),
        created_by: json['created_by'],
        created_time: DateTime.parse(json['created_time']),
        job_status: json['job_status']);
  }
  static List<String> convertCate_id(List<dynamic> json) {
    if (json == null)
      return null;
    else {
      List<String> data = [];
      json.forEach((f) => data.add(f.toString()));
      return data;
    }
  }
}
