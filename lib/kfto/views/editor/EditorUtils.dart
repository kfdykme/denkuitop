import 'dart:io';

import 'package:denkuitop/common/ColorManager.dart';
import 'package:denkuitop/common/Path.dart';
import 'package:flutter/foundation.dart';

String getDefaultUrl() {
  var homePath = DenkuiRunJsPathHelper.GetResourcePath();
  /**
       * home= 必须要是最
       */
  if (Platform.isWindows) {
    homePath = homePath.replaceAll("\\", "\\\\");
  }
  var url =
      "http://localhost:10825/index.html?isDarkMode=${ColorManager.instance().isDarkmode}&home=${homePath}/manoco-editor";


  if (kDebugMode) {
    url = "http://localhost:3000/";
  }
  return url;
}
