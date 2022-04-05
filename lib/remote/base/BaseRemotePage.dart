
import 'package:denkuitop/denkui/ipc/IpcClient.dart';
import 'package:denkuitop/denkui/ipc/async/AsyncIpcClient.dart';
import 'package:flutter/material.dart';

class BaseRemotePage extends StatefulWidget {
  BaseRemotePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  BaseRemotePageState createState() => BaseRemotePageState();
}


class BaseRemotePageState extends State<BaseRemotePage> {
  
  IpcClient _ipcClient = null;

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

  BaseRemotePage() {
    init();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(child: Text('BaseRemotePageState'));
  }

}