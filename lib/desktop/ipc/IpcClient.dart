import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:denkuitop/proto/ipc.pb.dart';

class IpcClient {
  var mWebSocket;

  List<Function> listeners = new List();

  var inited = false;

  IpcClient() {
    init();
  }

  init() async {
    if (inited) {
      // print("IpcClient has already inited");
      return;
    }
    mWebSocket = IOWebSocketChannel.connect("ws://127.0.0.1:8082");
    print("IpcClient init");
    inited = true;
    mWebSocket.stream.listen((message) {
      print("IpcClient  message ${message}");
      listeners.forEach((callback) {
        callback(message);
      });
    });
    this.send("DENKUI_START");
    this.addCallback((String message) async {
      this.send("RECEIVE");
      await new Future.delayed(const Duration(seconds: 5));
      this.send("DENKUI_ON_ATTACH_VIEW_END");
    });

  }

  send(dynamic data) {
    if (mWebSocket != null) {
      print("IpcClient send ${data}");
      print(mWebSocket.hashCode);
      mWebSocket.sink.add(data);
    }
  }

  addCallback(Function callback) {
    listeners.add(callback);
  }
}
