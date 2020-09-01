
import 'package:web_socket_channel/io.dart';
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
    mWebSocket = IOWebSocketChannel.connect("ws://127.0.0.1:8082", headers:  {
      'Origin':'http://127.0.0.1'
    });
    print("IpcClient init");
    inited = true;
    mWebSocket.stream.listen((message) {
      print("IpcClient  message ${message}");
      listeners.forEach((callback) {
        callback(message);
      });
    });
    this.send("DENKUI_START");

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
