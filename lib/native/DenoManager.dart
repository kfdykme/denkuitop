

import 'package:denkuitop/common/Path.dart';
import 'package:libdeno_plugin/libdeno_plugin.dart';

class DenoManager {

    static int port = 8082;

    Libdeno libdeno = Libdeno();
    DenoManager() {

    }
    

    startDeno() {
      print("DenoManager startDeno");
      var runableJsPath = DenkuiRunJsPathHelper.GetDenkBundleJsPath();
      print("${runableJsPath}");
      var isDevDeno = true;
      if (isDevDeno) {
        port = 8082;
      } else {
        libdeno.load();
        libdeno.run("deno run -A ${runableJsPath} --port=${port}");
      }
    }
}