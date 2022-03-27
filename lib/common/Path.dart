import 'package:denkuitop/common/Os.dart';

String get DirSpelator {
  if (isWindows()) {
    return '\\';
  } else {
    return '/';
  } 
}

String GetDirFromPath(String filePath) {
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
  return filePath.substring(filePath.lastIndexOf(DirSpelator) + DirSpelator.length);
}
