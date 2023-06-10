import 'dart:collection';

import 'package:denkuitop/common/Logger.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

Logger logger = Logger("IpcClient");
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

    logger.log("IpcClient init ${port}");
    inited = true;
    mWebSocket.stream.listen((message) {
      if (!message.toString().contains('"name":"heart"')) {
        // logger.log("IpcClient  message ${message}");
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
      // logger.log("IpcClient has already inited");
      return;
    }
    inited = true;

    // start deno process

    _tryConnect(port);
  }

  send(dynamic data) {
    if (mWebSocket != null) {
      logger.log("IpcClient send ${data}");
      mWebSocket.sink.add(data);
    } else {
      logger.log("IpcClient is not inited ${isConnected}");
    }
  }

  addCallback(Function callback) {
    listeners.add(callback);
  }

  setCallback(String key, Function callback) {
    callbacks[key] = callback;
  }
  
  void _tryConnect(int port) {
    if (this.isConnected) {
        return;
      }
      logger.log("Try Connect Socket ${port}");
      try {
        this.initSocket(port);
      } catch (e) {
        logger.log("Try Connect Socket fail" + e.toString());
        Future.delayed(Duration(microseconds: 50)).then((value) => _tryConnect(port));
      }
  }
}
