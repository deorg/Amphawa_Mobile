import 'package:amphawa/helper/httpService.dart';
import 'package:http/http.dart';

class DeptService {
  static const _host = HttpService.host;
  static const _getDeptUrl = _host + HttpService.getDepartment;

  static Future fetchDept(
      {Function onFetchFinished,
      Function onfetchTimeout,
      Function onFetchError}) async {
        print('fetching');
    await get(_getDeptUrl)
        .then((Response response) {
          onFetchFinished(response);
        })
        .timeout(Duration(seconds: 60), onTimeout: onfetchTimeout)
        .catchError((onError) => onFetchError(onError));
  }
}
