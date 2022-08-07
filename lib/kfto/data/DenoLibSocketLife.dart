

import 'package:denkuitop/denkui/ipc/IpcClient.dart';
import 'package:denkuitop/denkui/ipc/async/AsyncIpcClient.dart';
import 'package:denkuitop/kfto/data/KftodoListData.dart';
import 'package:denkuitop/native/DenoManager.dart';

/**
 * 用于管理与deno模块通信
 */
class DenoLibSocketLife {

  IpcClient _ipcClient = null;

  var isFirstConnect = false;
  

  Function handleIpcMessageCallback = null;

  Function onConnectedCallback = null;

  void init ({
    IpcClient client = null,
    int port: 7999
  }) {
    print("BaseRemotePageState init");
    _ipcClient = client;
    if (_ipcClient == null) {
      _ipcClient = IpcClient();
    }
    _ipcClient.init(port: port);
    
    _ipcClient.setCallback("onmessage", (String message) async {
      print(message);
//      await new Future.delayed(const Duration(seconds: 5));
    });
  }

  IpcClient ipc() {
    return _ipcClient;
  }


  DenoLibSocketLife() {
    init(client: new AsyncIpcClient(), port: DenoManager.port);
    this.ipc().setCallback("onmessage", (String message) async {
      // print(message);
      handleIpcMessage(KfToDoIpcData.raw(message));
    });
    
  }

  void onConnected() {
      this.ipc().send(KfToDoIpcData.from('onFirstConnect', null).json());
      isFirstConnect = true;
      if (onConnectedCallback != null) {
        onConnectedCallback();
      }
  }
  
  void handleIpcMessage(raw) {
    if (!isFirstConnect) {
      onConnected();
    }

    if (handleIpcMessageCallback != null) {
      handleIpcMessageCallback(raw);
    }
  }
}