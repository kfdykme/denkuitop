

class Logger {
  String baseName;

  Logger(String s) {
    init(s);
  }
  init(String name) {
    baseName = name;
  }

  log(Object object) {
    
    print('${new DateTime.now().toLocal()} [${baseName}] ${object}');
  }
}
