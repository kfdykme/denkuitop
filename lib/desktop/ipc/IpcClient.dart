import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:denkuitop/proto/ipc.pb.dart';

class IpcClient {
  var mWebSocket;

  List<Function> listeners = new List();

  IpcClient() {
    init();
  }
  
  init() async {
     mWebSocket = IOWebSocketChannel.connect("ws://127.0.0.1:8089");

    mWebSocket.stream.listen((message) {
      listeners.forEach((callback) {
        callback(message);
      });
      send("received: ${message}");
    });
  }

  send(dynamic data) {
    if (mWebSocket != null) {
      var invoke = IpcInvoke.create();
      invoke.module = "test";
      invoke.method = "print(${data})";

      var a = invoke.writeToJson();
      print(a);
      mWebSocket.sink.add(a);
    }
  }

  addCallback(Function callback) {
    listeners.add(callback);
  }


}