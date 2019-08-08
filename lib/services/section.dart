import 'package:amphawa/helper/httpService.dart';
import 'package:http/http.dart';

class SectService {
  static const _host = HttpService.host;
  static const _getSectUrl = _host + HttpService.getSection;

  static Future fetchSect(
      {String dept_id,
      Function onFetchFinished,
      Function onfetchTimeout,
      Function onFetchError}) async {
    print('fetching');
    await get('$_getSectUrl?dept_id=$dept_id')
        .then((Response response) {
          onFetchFinished(response);
        })
        .timeout(Duration(seconds: 60), onTimeout: onfetchTimeout)
        .catchError((onError) => onFetchError(onError));
  }
}
