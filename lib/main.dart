import 'dart:convert';

import 'package:denkuitop/desktop/data/IpcData.dart';
import 'package:denkuitop/desktop/data/TestRenderData.dart';
import 'package:denkuitop/desktop/data/View.dart';
import 'package:denkuitop/desktop/render/BaseRender.dart';
import 'package:flutter/material.dart';
import 'package:denkuitop/desktop/ipc/IpcClient.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        backgroundColor: Colors.white,
        fontFamily: 'ZCOOL',
        appBarTheme: null,
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
  var ipcClient = IpcClient();
  var baseRender = BaseRender();

  List<Widget> viewStack;

  Scaffold view;

  String promptText = "";

  bool isFirst = true;
  _MyHomePageState() {
    viewStack = [BaseRender.RenderEmpty(), BaseRender.RenderEmpty()];
  }

  void handleIpcMessage(IpcData ipcData) {
    switch (ipcData.method) {
      case "RENDER_VIEW":
        if (ipcData.data != null) {
          renderView(ipcData.data);
        } else {
          print("RENDER_VIEW NULL");
          ipcClient.send("DENKUI_ON_ATTACH_VIEW_END");
        }
        break;
      case "UPDATE_VIEW":
        if (ipcData.data != null) {
          var map = ipcData.data as Map<String, dynamic>;
          var key = map['key'] as String;
          var value = map['value'].toString();

          // print(
          //     "handleIpcMessage UPDATE_VIEW: ${ipcData.data} -> {{${key}}} :${value}");
          // setState(() {
          //   _bodyView = _bodyView.replaceAll("{{${key}}}",
          //       "${Utf8Decoder().convert(Utf8Encoder().convert(value))}");
          // });
        }
        break;
      case "RENDER_VIEW_REPLACE":
        if (ipcData.data != null) {
          this.renderView(ipcData.data, isReplace: true);
        } else {
          print("RENDER_VIEW NULL");
          ipcClient.send("DENKUI_ON_ATTACH_VIEW_END");
        }
        break;
      case "PROMPT":
        if (ipcData.data != null) {
          setState(() {
            promptText = ipcData.data.toString();
          });
        }
        break;
      default:
        print("Main handleIpcMessage: ${ipcData.toString()}");
    }
  }

  void renderView(dynamic data, {bool isReplace = false}) {
    View view = new View(jsonDecode(data));
    //1

    setState(() {
      if (!isReplace && isFirst) {
        viewStack[0] = buildView(view);
      } else {
        viewStack[1] = buildView(view);
      }
      isFirst = false;
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

    ipcClient.setCallback("onmessage", (String message) async {
      var ipcData = new IpcData(message);
      handleIpcMessage(ipcData);
//      await new Future.delayed(const Duration(seconds: 5));
    });
    baseRender.bindIpc(ipcClient);
    baseRender.bindContext(context);
    view = Scaffold(
        backgroundColor: Colors.white,
        body: Row(
          children: viewStack,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ));

    return view;
  }

  buildViewFrom(json) {
    View view = View.fromString(json);
    return buildView(view);
  }

  buildView(View view) {
    return baseRender.RenderView(view);
  }
}
