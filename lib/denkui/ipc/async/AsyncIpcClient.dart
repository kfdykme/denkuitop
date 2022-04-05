
import 'dart:collection';

import 'package:denkuitop/common/Logger.dart';
import 'package:denkuitop/denkui/ipc/IpcClient.dart';
import 'package:denkuitop/denkui/ipc/async/AsyncIpcData.dart';

typedef AsyncIpcCallback = Function(AsyncIpcData data);

var logger = Logger('AsyncIpcClient');

class AsyncIpcClient extends IpcClient {
  
  Map<String, AsyncIpcCallback> asyncCallbacks = new Map<String,AsyncIpcCallback>();

  @override
  init({ int port = 7999}) {
    super.init( port: port);
    
    addCallback((String message) {
      logger.log('AsyncIpcClient base callback: ' + message);
      var ipcData = new AsyncIpcData.raw(message);
      logCallbacks();

      if (asyncCallbacks.containsKey(ipcData.id)) {
        asyncCallbacks[ipcData.id](ipcData);
        asyncCallbacks.remove(ipcData.id);
      }
    });
  }



  @override
  send(data) { 
    return super.send(data);
  }
  
  logCallbacks() {
    logger.log('callbacks' + asyncCallbacks.keys.length.toString());
    asyncCallbacks.keys.forEach((String element) {
      logger.log('callbacks key: ' + element.toString());
    });
  }

  invoke(AsyncIpcData data, {AsyncIpcCallback callback = null}) {
    logger.log('invoke  id :' + data.id+ 'callback :' +  callback.toString());
    if (callback != null) {
      data.isWait();
      asyncCallbacks[data.id] = callback;
      logCallbacks();
    }
    return super.send(data.json());
  }  
}