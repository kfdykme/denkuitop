import 'dart:convert';

import 'package:denkuitop/desktop/data/IpcData.dart';
import 'package:denkuitop/desktop/data/TestRenderData.dart';
import 'package:denkuitop/desktop/data/View.dart';
import 'package:flutter/material.dart';
import 'ipc/IpcClient.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  var ipcClient = IpcClient();

  String _bodyView = "";

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;

      ipcClient.send(_counter);
    });
  }

  void handleIpcMessage(IpcData ipcData) {
    switch(ipcData.method) {
      case "RENDER_VIEW":
        if (ipcData.data != null) {
          renderView(ipcData.data);
        } else {
          print ("RENDER_VIEW NULL");
        }
        ipcClient.send("DENKUI_ON_ATTACH_VIEW_END");
        break;
      case "UPDATE_VIEW":
        if (ipcData.data != null) {
          var map = ipcData.data as Map<String,dynamic>;
          var key = map['key'] as String;
          var value = map['value'].toString() ;
          setState(() {
            _bodyView = _bodyView.replaceAll("{{${key}}}", value);
          });
        }
        break;
      default:
        print("Main handleIpcMessage: ${ipcData.toString()}");
    }
  }

  void renderView(dynamic data) {
    print(data);
    View view = new View(jsonDecode(data));

    setState(() {
      _bodyView = data;
    });
    ipcClient.send("DENKUI_ON_ATTACH_VIEW_END");
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    ipcClient.init();
    ipcClient.addCallback((String message) async {
      var ipcData = new IpcData(message);
      handleIpcMessage(ipcData);
//      await new Future.delayed(const Duration(seconds: 5));
    });

//    var json = TestRenderData.get();
    var center;
    if (_bodyView != '') {
      center = buildViewFrom(_bodyView);
    } else {
      center = Center();
    }

    Scaffold scaffold = Scaffold(
        appBar: AppBar(
          title: Text("TEST_RENDER_DATA"),
        ),
        body: center
    );

    return scaffold;
  }

  buildViewFrom(json) {
    View view = View.fromString(json);
    return buildView(view);

  }

  buildView(View view) {
    print("BuildView form ${view.name}");
    List<Widget> childs = [];

    view.childs.forEach((element) {
      childs.add(buildView(element));
    });
    var res;
    if (view.name == "text") {
      print("BuidView build as text: ${view.name} -> ${view.content}");
      res = Text(view.content);
      return res;
    } else {
      print("BuildView build as center");
      res = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: childs,
        ),
      );
    }
    return res;
  }
}
