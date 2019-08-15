import 'dart:convert';
import 'package:amphawa/helper/httpService.dart';
import 'package:amphawa/model/job.dart';
import 'package:http/http.dart';
import 'package:dio/dio.dart' as dio;

class JobService {
  static const _host = HttpService.host;
  static const _getJobUrl = _host + HttpService.getJob;
  static const _createJobUrl = _host + HttpService.addJob;
  static const _updateJobUrl = _host + HttpService.updateJob;
  static const _deleteJobUrl = _host + HttpService.deleteJob;

  static Future fetchJob(
      {Function onFetchFinished,
      Function onfetchTimeout,
      Function onFetchError}) async {
    print('fetching');
    await get(_getJobUrl)
        .then((Response response) {
          onFetchFinished(response);
        })
        .timeout(Duration(seconds: 60), onTimeout: onfetchTimeout)
        .catchError((onError) => onFetchError(onError));
  }

  static Future createJob(
      {Job job,
      Function onSending,
      Function onSent,
      Function onSendTimeout,
      Function onSendCatchError}) async {
    Map<String, dynamic> body = job.toJson();
    dio.Dio httpClient = new dio.Dio();
    dio.DioHttpHeaders headers = new dio.DioHttpHeaders();
    headers.add('Content-Type', 'application/json');
    httpClient
        .post(_createJobUrl,
            data: body,
            options: dio.Options(headers: {'Content-Type': 'application/json'}),
            onSendProgress: onSending)
        .then((res) {
          onSent(res);
        })
        .timeout(Duration(seconds: 60), onTimeout: onSendTimeout)
        .catchError((onError) {
          onSendCatchError(onError);
        });
  }

  static Future updateJob(
      {Job job,
      Function onSending,
      Function onSent,
      Function onSendTimeout,
      Function onSendCatchError}) async {
    Map<String, dynamic> body = job.toJson();
    dio.Dio httpClient = new dio.Dio();
    dio.DioHttpHeaders headers = new dio.DioHttpHeaders();
    headers.add('Content-Type', 'application/json');
    httpClient
        .post(_updateJobUrl,
            data: body,
            options: dio.Options(headers: {'Content-Type': 'application/json'}),
            onSendProgress: onSending)
        .then((res) {
          onSent(res);
        })
        .timeout(Duration(seconds: 60), onTimeout: onSendTimeout)
        .catchError((onError) {
          onSendCatchError(onError);
        });
  }

  static Future deleteJob(
      {int job_id,
      Function onDeleted,
      Function onDeleteTimeout,
      Function onDeleteCatchError}) async {
    print('deleting');
    await get('$_deleteJobUrl?job_id=$job_id')
        .then((Response response) {
          onDeleted(response);
        })
        .timeout(Duration(seconds: 60), onTimeout: onDeleteTimeout)
        .catchError((onError) => onDeleteCatchError(onError));
  }
}
