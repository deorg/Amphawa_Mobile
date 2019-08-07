import 'dart:convert';
import 'package:amphawa/helper/httpService.dart';
import 'package:amphawa/model/job.dart';
import 'package:http/http.dart';
import 'package:dio/dio.dart' as dio;

class JobService {
  static const _host = HttpService.host;
  static const _getJobUrl = _host + HttpService.getJob;
  static const _createJobUrl = _host + HttpService.addJob;

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

  static Future createJob({Job job, Function onSending, Function onSent, Function onSendTimeout, Function onSendCatchError}) async {
    Map<String, dynamic> body = job.toJson();
    dio.Dio httpClient = new dio.Dio();
    dio.DioHttpHeaders headers = new dio.DioHttpHeaders();
    headers.add('Content-Type', 'application/json');
    httpClient.post(_createJobUrl,
        data: body,
        options: dio.Options(headers: {'Content-Type': 'application/json'}),
        onSendProgress: onSending
    ).then((res) {
      onSent(res);
    }
    ).timeout(Duration(seconds: 60), onTimeout: onSendTimeout).catchError((onError) {
      onSendCatchError(onError);
    });
  }
}