import 'dart:io';

import 'package:denkuitop/common/Os.dart';

String get DirSpelator {
  if (isWindows()) {
    return '\\';
  } else {
    return '/';
  }
}

String GetDirFromPath(String filePath) {
  if (filePath == null) return '';
  if (filePath == '') return filePath;
  if (filePath.endsWith(DirSpelator)) {
    return filePath;
  }
  return filePath.substring(0, filePath.lastIndexOf(DirSpelator));
}

String GetFileNameFromPath(String filePath) {
  if (filePath.endsWith(DirSpelator)) {
    return '';
  }
  return filePath
      .substring(filePath.lastIndexOf(DirSpelator) + DirSpelator.length);
}

class DenkuiRunJsPathHelper {
  static String GetResourcePath() {
    if (Platform.isMacOS) {
      var executableDirPath = Platform.resolvedExecutable
          .substring(0, Platform.resolvedExecutable.lastIndexOf('/LowHumming'));
      var runableJsPath = "${executableDirPath + '/../Resources'}";
      return runableJsPath;
    } else if (Platform.isWindows) {
      var executableDirPath = Platform.resolvedExecutable.substring(
          0, Platform.resolvedExecutable.lastIndexOf('denkuitop.exe'));
      return executableDirPath;
    }

    return '';
  }

  static String GetDenkBundleJsPath() {
    if (Platform.isMacOS) {
      var executableDirPath = Platform.resolvedExecutable
          .substring(0, Platform.resolvedExecutable.lastIndexOf('/LowHumming'));
      print("GetDenkBundleJsPath ${Platform.resolvedExecutable}");
      var runableJsPath =
          "${executableDirPath + '/../Resources/denkui.bundle.js'}";
      return runableJsPath;
    } else if (Platform.isWindows) {
      var executableDirPath = Platform.resolvedExecutable.substring(
          0, Platform.resolvedExecutable.lastIndexOf('denkuitop.exe'));
      var runableJsPath = "${executableDirPath + '.\\denkui.bundle.js'}";
      return runableJsPath;
    }

    return '';
  }

  static String GetPreloadPath() {
    if (Platform.isMacOS) {
      var executableDirPath = Platform.resolvedExecutable
          .substring(0, Platform.resolvedExecutable.lastIndexOf('/LowHumming'));
      var runableJsPath = "${executableDirPath + '/../Resources/preload.js'}";
      return runableJsPath;
    } else if (Platform.isWindows) {
      var executableDirPath = Platform.resolvedExecutable.substring(
          0, Platform.resolvedExecutable.lastIndexOf('denkuitop.exe'));
      var runableJsPath = "${executableDirPath + '.\\preload.js'}";
      return runableJsPath;
    }

    return '';
  }
}
