import 'dart:collection';

import 'package:web_socket_channel/io.dart';
import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

class IpcClient {
  var mWebSocket;

  List<Function> listeners = <Function>[];

  Map<String, Function> callbacks = new HashMap();

  var inited = false;
  var isConnected = false;

  IpcClient() {
//    init();
  }

  initSocket(int port) {
    mWebSocket = IOWebSocketChannel.connect("ws://127.0.0.1:${port}",
        headers: {'Origin': 'http://127.0.0.1'});

    print("IpcClient init ${port}");
    inited = true;
    mWebSocket.stream.listen((message) {
      if (!message.toString().contains('"name":"heart"')) {
        // print("IpcClient  message ${message}");
      }
      isConnected = true;
      listeners.forEach((callback) {
        callback(message);
      });
      if (callbacks["onmessage"] != null) callbacks["onmessage"](message);
    });
    // this.send("DENKUI_START");
  }

  init({int port = 7999}) async {
    if (inited) {
      // print("IpcClient has already inited");
      return;
    }

    // start deno process

    Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      if (this.isConnected) {
        timer.cancel();
      }
      print("Try Connect Socket ${port}");

      try {
        this.initSocket(port);
      } catch (e) {
        print("Try Connect Socket fail" + e.toString());
      }
    });
  }

  send(dynamic data) {
    if (mWebSocket != null) {
      print("IpcClient send ${data}");
      mWebSocket.sink.add(data);
    }
  }

  addCallback(Function callback) {
    listeners.add(callback);
  }

  setCallback(String key, Function callback) {
    callbacks[key] = callback;
  }
}
