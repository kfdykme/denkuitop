
import 'dart:convert';

import 'package:denkuitop/desktop/data/IpcData.dart';
import 'package:denkuitop/desktop/data/View.dart';
import 'package:denkuitop/desktop/ipc/IpcClient.dart';
import 'package:denkuitop/desktop/render/BaseRender.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BasePage extends StatefulWidget {
  BasePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  BasePageState createState() => BasePageState();
}

class BasePageState extends State<BasePage> {
  var ipcClient = IpcClient();
  var baseRender = BaseRender();

  List<Widget> viewStack;

  Scaffold view;

  String promptText = "";
  
  bool isSinglePage = true;

  bool isFirst = true;
  BasePageState() {
    viewStack = isSinglePage ? [BaseRender.RenderEmpty()] :[BaseRender.RenderEmpty(),
      SizedBox(
          width: 1,
          height: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
             boxShadow: <BoxShadow>[
    	 BoxShadow(
         	color: Colors.black
         ),
         BoxShadow(
         	color: Colors.white,
         ),
	]),
            
          ),
        ),
     BaseRender.RenderEmpty()];
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
      if ((!isReplace && isFirst) || isSinglePage) {
        viewStack[0] = buildViewLeft(view);
      } else {
        viewStack[2] = buildView(view);
      }
      isFirst = false;
    });

    ipcClient.send("DENKUI_ON_ATTACH_VIEW_END");
  }

  @override
  Widget build(BuildContext context) {
    
    
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
          mainAxisAlignment: MainAxisAlignment.start,
        ));

    return view;
  }

  buildViewFrom(json) {
    View view = View.fromString(json);
    return buildView(view);
  }

  buildView(View view) {
    return baseRender.RenderView(view,
    isLeftView: true);
  }

  buildViewLeft(View view) {
    return baseRender.RenderView(view, 
    isLeftView :true,
    isRootView: true,
    );
  }
}
