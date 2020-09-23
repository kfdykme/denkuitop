import 'package:denkuitop/desktop/data/View.dart';
import 'package:denkuitop/desktop/ipc/IpcClient.dart';
import 'package:denkuitop/desktop/render/Components.dart';
import 'package:denkuitop/desktop/render/RenderCheck.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';

class BaseRender {
  IpcClient ipc = null;
  RenderCheck renderCheck = RenderCheck();

  BaseRender() {}

  bindIpc(IpcClient ipcClient) {
    this.ipc = ipcClient;
  }

  RenderTabs(View view, List<Widget> childs) {
    View tabContentView =
        view.childs.singleWhere((element) => element.name == "tab-content");
    if (tabContentView == null) {
      return Text(view.name);
    } else {
      int tabIndex = 0;
      try {
        tabIndex = int.parse(view.jsonParams["index"]);
      } on Exception catch (e) {
        print(e);
      }
      print("BuildView RenderTabs index: ${tabIndex}");
      return Center(child: RenderView(tabContentView.childs[tabIndex]));
    }
  }

  RenderInput(View view) {
    return TextField(
      obscureText: view.jsonParams["type"] == "password",
      onChanged: (value) {
        // UpdateValue(view, key, value)
        UpdateValue(view, view.jsonParams["id"], value);
        InvokeMethod(
            view, GetFunction(view, "change"), "{ \"value\": \"${value}\"}");
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
      params = func.substring(func.indexOf("(") + 1, func.length - 1);
    }
    return params;
  }

  RenderText(View view) {
    print("BuidView build as text: ${view.name} -> ${view.jsonParams}");

    var text = view.content;
    if (view.jsonParams.values.length != 0) text += "-> ${view.jsonParams}";

    if (GetFunction(view, "click") != null) {
      return RaisedButton(
        onPressed: () {
          InvokeMethod(
              view, GetFunction(view, "click"), GetParams(view, "click"));
        },
        color: Colors.white,
        hoverColor: Colors.white12,
        child: Text(text),
      );
    } else {
      return Text(text);
    }
  }

  RenderButton(View view) {
    return RaisedButton(
        onPressed: () {
          InvokeMethod(
              view, GetFunction(view, "click"), GetParams(view, "click"));
        },
        child: Text(view.jsonParams['value']));
  }

  RenderNull(View view) {
    var text = view.name;
    if (view.jsonParams.values.length != 0) text += "-> ${view.jsonParams}";
    return Text(text);
  }

  static RenderEmpty() {
    return Container(
      width: 350,
      color: Colors.red,
    );
  }

  RenderContainor(View view, List<Widget> childs) {
    print("BuildView build as center");
    childs.insert(0, RenderNull(view));

    return SingleChildScrollView(
      child: Container(
        width: 350,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: childs,
        ),
      )
    ) ;
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

    view?.childs.forEach((element) {
      if (renderCheck.IsShow(element)) {
        childs.add(RenderView(element));
      }
    });

    view?.components?.forEach((element) {
      Components.register(element);
    });
    var res;
    if (renderCheck.IsText(view)) {
      return RenderText(view);
    } else if (renderCheck.IsContainor(view)) {
      return RenderContainor(view, childs);
    } else if (renderCheck.IsTabs(view)) {
      return RenderTabs(view, childs);
    } else if (renderCheck.IsButton(view)) {
      return RenderButton(view);
    } else if (renderCheck.IsInput(view)) {
      return RenderInput(view);
    } else if (renderCheck.IsStack(view)) {
      return RenderContainor(view, childs);
    } else if (renderCheck.IsComponents(view)) {
      View component = Components.get(view.name);
      component.name = "view";
      return RenderView(component);
    } else if (renderCheck.IsRefresh(view)) {
      return RenderContainor(view, childs);
    } else if (renderCheck.IsList(view)) {
      return RenderContainor(view, childs);
    } else {
      return RenderNull(view);
    }
    return res;
  }
}
