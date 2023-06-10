

import 'package:dio/dio.dart';

class NetworkUtils {

  // 根据url获取html title
  Future<String> getTitleFromUrl(String url) {
    print("NetworkUtils getTitleFromUrl $url");
    if (!url.startsWith("http")) {
      return Future.value("");
    }
    try {
      return Dio().get(url).then((value) {
        var htmlText = value.toString();
        var regresult = RegExp("<title>(.*?)</title>").allMatches(htmlText);
        var title = regresult.first.group(1);

        return title;
      });
    } catch(err) {
      return Future.value("");
    }
  }
}