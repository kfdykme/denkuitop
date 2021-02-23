import 'package:denkuitop/desktop/data/View.dart';
import 'package:denkuitop/desktop/ipc/IpcClient.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';

class BaseRender {
  IpcClient ipc = null;

  BaseRender() {}

  bindIpc(IpcClient ipcClient) {
    this.ipc = ipcClient;
  }

  IsText(View view) {
    return view.name == "text";
  }

  IsContainor(View view) {
    return view.name == "template" || view.name == "view" || view.name == "div";
  }

  IsTabs(View view) {
    return view.name == "tabs";
  }

  IsTabContent(View view) {
    return view.name == "tab-content";
  }

  IsButton(View view) {
    return view.name == 'input' &&
        view.jsonParams["type"] != null &&
        view.jsonParams["type"] == "button";
  }

  IsInput(View view) {
    return view.name == 'input' &&
        (view.jsonParams["type"] == null ||
            view.jsonParams["type"] == "text" ||
            view.jsonParams["type"] == "password");
  }

  IsStack(View view) {
    return view.name == 'stack';
  }

  
  IsShow(View view) {
    print("BuildView IsShow ${view.name} ${view.jsonParams["show"]} ${view.jsonParams["show"] == "false"}");
    return !(view.jsonParams["show"] == "false"); 
  }
 

  RenderTabs(View view, List<Widget> childs) {
    View tabContentView = view.childs.singleWhere((element) => element.name == "tab-content");
    if (tabContentView == null) {
      return Text(view.name);
    } else {
      int tabIndex = int.parse(view.jsonParams["index"]);
      
      print("BuildView RenderTabs index: ${tabIndex}");
      return Center(
        child:RenderView(tabContentView.childs[tabIndex])
      );
    }
  }

  RenderInput(View view) {
    return TextField(
      obscureText: view.jsonParams["type"] == "password",
      onChanged: (value) {
        // UpdateValue(view, key, value)
        UpdateValue(view, view.jsonParams["id"], value);
        InvokeMethod(view, "onchange", "{ \"value\": \"${value}\"}");
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: view.jsonParams["placeholder"],
      ),
    );
  }

  GetFunction(View view, String type) {
    String func = view.jsonParams['@' + type];
    if (func == null) {
      func = view.jsonParams['on' + type];
    }

    if (func != null && func.indexOf("(") != -1) { 
      func = func.substring(0, func.indexOf("("));
    }

    return func;
  }

  GetParams(View view, String type) {
    String params = '{}';
    String func = view.jsonParams['@' + type];
    if (func == null) {
      func = view.jsonParams['on' + type];
    }

    if (func != null && func.indexOf("(") != -1) {
      params =  func.substring(func.indexOf("(") +1, func.length-1); 
    }
    return params;
  }

  RenderText(View view) {
    print("BuidView build as text: ${view.name} -> ${view.jsonParams}");
    
    var text = view.renderContent;
    if (view.jsonParams.values.length != 0) text += "-> ${view.jsonParams}";
    
    if (GetFunction(view, "click") != null) {

      return RaisedButton(
          onPressed: () {
            InvokeMethod(view, 
              GetFunction(view, "click"),
              GetParams(view, "click"));
          }, 
          color: Colors.white,
          hoverColor:Colors.white12,
          child: Text(text),
          );
    } else {
      return Text(text);
    }
  }

  RenderButton(View view) {
    return RaisedButton(
        onPressed: () {
            InvokeMethod(view, 
              GetFunction(view, "click"),
              GetParams(view, "click"));
        },
        child: Text(view.jsonParams['value']));
  }

  RenderNull(View view) {
    var text = view.name;
    if (view.jsonParams.values.length != 0) text += "-> ${view.jsonParams}";
    return Text(text);
  }

  RenderContainor(View view, List<Widget> childs) {
    print("BuildView build as center");
    // childs.insert(0, RenderNull(view));
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: childs,
      ),
    );
  }

  UpdateValue(View view, String key, String value) {
    Map<String, dynamic> map = new Map();
    map["mod"] = "changevalue";
    map["key"] = key;
    map["value"] = value;
    ipc.send(jsonEncode(map));
  }

  InvokeMethod(View view, String func, String params) {
    Map<String, dynamic> map = new Map();
   
    map["mod"] = "invoke";
    map["function"] = func;
    map["param"] = params;
    ipc?.send(jsonEncode(map));
  }


  RenderView(View view) {
    print("BuildView form ${view.name}");
    List<Widget> childs = [];

    view.childs.forEach((element) {
      if (IsShow(element)) {
        childs.add(RenderView(element));
      }
    });
    var res;
    if (IsText(view)) {
      return RenderText(view);
    } else if (IsContainor(view)) {
      return RenderContainor(view, childs);
    } else if (IsTabs(view)) {
      return RenderTabs(view, childs);
    } else if (IsButton(view)) {
      return RenderButton(view);
    } else if (IsInput(view)) {
      return RenderInput(view);
    } else if (IsStack(view)) {
      return RenderContainor(view, childs);
    } else {
      return RenderNull(view);
    }
    return res;
  }
}
