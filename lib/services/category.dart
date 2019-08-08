import 'package:amphawa/helper/httpService.dart';
import 'package:http/http.dart';

class CategoryService {
  static const _host = HttpService.host;
  static const _getSectUrl = _host + HttpService.getCategory;

  static Future fetchCategory(
      {Function onFetchFinished,
      Function onfetchTimeout,
      Function onFetchError}) async {
        print('fetching');
    await get(_getSectUrl)
        .then((Response response) {
          onFetchFinished(response);
        })
        .timeout(Duration(seconds: 60), onTimeout: onfetchTimeout)
        .catchError((onError) => onFetchError(onError));
  }
}