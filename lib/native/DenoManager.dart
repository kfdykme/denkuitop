

import 'package:denkuitop/common/Path.dart';
import 'package:libdeno_plugin/libdeno_plugin.dart';

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

    Future<bool> isSupport() {
      return libdeno.isSupport();
    }
    

    Future<bool> startDeno() async {
      print("DenoManager startDeno");
      var runableJsPath = DenkuiRunJsPathHelper.GetDenkBundleJsPath();
      print("${runableJsPath}");
      var isDevDeno = false;
      if (isDevDeno) {
        port = 8673;
      } else {
        bool isSupport = await libdeno.isSupport();
        
        if (isSupport) {
          libdeno.load();
          libdeno.run("deno run -A ${runableJsPath} --port=${port}");
        } else {
          return false;
        }
      }
      return true;
    }
}