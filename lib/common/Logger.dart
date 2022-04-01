

class Logger {
  String baseName;

  Logger(String s) {
    init(s);
  }
  init(String name) {
    baseName = name;
  }

  log(Object object) {
    print('');
    print('⌈ ' + baseName + '------------------');
    print('  ' + object);
    print('⌊ ' + baseName + '------------------');
    print('');
  }
}