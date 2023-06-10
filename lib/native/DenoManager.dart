

import 'package:denkuitop/common/Logger.dart';
import 'package:denkuitop/common/Path.dart';
import 'package:libdeno_plugin/libdeno_plugin.dart';

Logger logger = Logger("DenoManager");
class DenoManager {

    static int port = 8673;

    Libdeno libdeno = Libdeno();
    DenoManager() {

    }

    static DenoManager _ins;

    static DenoManager Instance() {
      if (_ins == null) {
        _ins = new DenoManager();
      } 
      return _ins;
    }


    onData(Function f) {
      libdeno.onData(f);
    }

    send(String data) {
      libdeno.send(data);
    }
    Future<bool> startDeno() async {
      logger.log("DenoManager startDeno");
      var runableJsPath = DenkuiRunJsPathHelper.GetDenkBundleJsPath();
      print("${runableJsPath}");
      var isDevDeno = false;
      if (isDevDeno) {
        port = 8673;
      } else {
        libdeno.load();
        final cmd = "deno run -A ${runableJsPath} --port=${port}";
        libdeno.run(cmd);
      }
      return true;
    }
}