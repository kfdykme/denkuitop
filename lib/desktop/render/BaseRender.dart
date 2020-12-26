import 'package:denkuitop/desktop/data/View.dart';
import 'package:denkuitop/desktop/ipc/IpcClient.dart';
import 'package:denkuitop/desktop/render/Components.dart';
import 'package:denkuitop/desktop/render/RenderCheck.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';

class BaseRender {
  IpcClient ipc = null;
  BuildContext context = null;
  RenderCheck renderCheck = RenderCheck();
  SnackBar lastSnackBar = null;

  BaseRender() {}

  bindIpc(IpcClient ipcClient) {
    this.ipc = ipcClient;
  }

  bindContext(BuildContext context) {
    this.context = context;
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
    var margin = null;
    view.styles.where((element) => element.hasCss("margin")).forEach((element) {
      margin = element.getCssSize("margin");
    });

    var padding = null;
    view.styles
        .where((element) => element.hasCss("padding"))
        .forEach((element) {
      padding = element.getCssSize("padding");
    });

    var width = null;
    view.styles.where((element) => element.hasCss("width")).forEach((element) {
      width = element.getCssSize("width");
    });

    var height = null;
    view.styles.where((element) => element.hasCss("height")).forEach((element) {
      height = element.getCssSize("height");
    });

    print("RenderInput ${view} ${margin} ${padding} ${width} ${height}");
    view.styles.forEach((element) {
      print(element);
    });

    return new Container(
      child: TextField(
        obscureText: view.jsonParams["type"] == "password",
        onChanged: (value) {
          // UpdateValue(view, key, value)
          UpdateValue(view, view.jsonParams["id"], value);
          InvokeMethod(
              view, GetFunction(view, "change"), "{ \"value\": \"${value}\"}");
        },
        decoration: InputDecoration(
          // border: OutlineInputBorder(),
          labelText: view.jsonParams["placeholder"],
        ),
      ),
      height: height,
      width: width,
      padding: padding == null ? null : new EdgeInsets.all(padding),
      margin: margin == null ? null : new EdgeInsets.all(margin),
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

  _ShowText(BuildContext context, String text) {
    if (lastSnackBar != null) {
      Scaffold.of(context).removeCurrentSnackBar();
      lastSnackBar = null;
    }
    lastSnackBar = new SnackBar(
      content: new Text(text),
    );
    Scaffold.of(context).showSnackBar(lastSnackBar);
  }

  RenderText(View view) {
    print("BuidView build as text: ${view.name} -> ${view.jsonParams}");

    var text = view.content;
    // if (view.jsonParams.values.length != 0) text += "-> ${view.jsonParams}";
    var color = null;
    view.styles.where((element) => element.hasCss("color")).forEach((element) {
      color = element.getCssColor("color");
    });

    var fontSize = null;
    view.styles
        .where((element) => element.hasCss("font-size"))
        .forEach((element) {
      fontSize = element.getCssSize("font-size");
    });
    var textView = Text(
      text,
      style: new TextStyle(color: color, fontSize: fontSize ),
    );
    print("RenderText Color: ${color} with ${text} at ${fontSize}");

    if (GetFunction(view, "click") != null) {
      return new Center(
        child: new Builder(builder: (BuildContext context) {
          return RaisedButton(
            onPressed: () {
              _ShowText(context, "${view.jsonParams}");
              InvokeMethod(
                  view, GetFunction(view, "click"), GetParams(view, "click"));
            },
            child: textView,
          );
        }),
      );
    } else {
      return textView;
    }
  }

  RenderButton(View view) {
    var margin = null;
    view.styles.where((element) => element.hasCss("margin")).forEach((element) {
      margin = element.getCssSize("margin");
    });

    var padding = null;
    view.styles
        .where((element) => element.hasCss("padding"))
        .forEach((element) {
      padding = element.getCssSize("padding");
    });

    var width = null;
    view.styles.where((element) => element.hasCss("width")).forEach((element) {
      width = element.getCssSize("width");
    });

    var height = null;
    view.styles.where((element) => element.hasCss("height")).forEach((element) {
      height = element.getCssSize("height");
    });

    var background = null;
    view.styles
        .where((element) => element.hasCss("background-color"))
        .forEach((element) {
      background = element.getCssColor("background-color");
    });

    var color = null;
    view.styles.where((element) => element.hasCss("color")).forEach((element) {
      color = element.getCssColor("color");
    });
    var fontSize = null;
    view.styles
        .where((element) => element.hasCss("font-size"))
        .forEach((element) {
      fontSize = element.getCssSize("font-size");
    });
    print(
        "RenderButton ${view.name} -> ${view.jsonParams} ${margin} ${padding} ${width} ${height} ${color} ${background}");
    return ButtonTheme(
      child: RaisedButton(
        onPressed: () {
          InvokeMethod(
              view, GetFunction(view, "click"), GetParams(view, "click"));
        },
        child: Text(
          view.jsonParams['value'],
          style: new TextStyle(
            letterSpacing: 10,
              color: color, fontSize: fontSize),
        ),
      ),
      buttonColor: background,

      height: height == null ? 36.0 : height,
      minWidth: width == null ? 88.0 : width,
      padding: padding == null ? null : new EdgeInsets.all(padding),
      // margin: margin == null ? null : new EdgeInsets.all(margin),
    );
  }

  RenderNull(View view) {
    var text = view.name;
    if (view.jsonParams.values.length != 0) text += "-> ${view.jsonParams}";
    return new Builder(builder: (BuildContext context) {
      return TextButton(
        onPressed: () {
          _ShowText(context, text);
        },
        child: Text(view.name),
      );
    });
  }

  static RenderEmpty() {
    return Container(
      width: 350,
      color: Colors.white,
      // color: Colors.red,
    );
  }

  RenderContainor(View view, List<Widget> childs) {
    print("BuildView build as center");
    // if (childs.length > 2) childs.insert(0, RenderNull(view));
    var height = null;
    view.styles.where((element) => element.hasHeight()).forEach((element) {
      height = element.height();
    });

    var backgroundColor = Colors.white;
    view.styles
        .where((element) => element.hasBackgroundColor())
        .forEach((element) {
      backgroundColor = element.backgroundColor();
    });

    // childs.insert(0, new Text("${height}"));
    return SingleChildScrollView(
        child: Container(
      width: 350,
      height: height,
      decoration: BoxDecoration(
          // border: Border.all(width: 2.0, color: const Color(0xFFFFFFFF)),
          color: backgroundColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: childs,
      ),
    ));
  }

  RenderProgress(View view) {
    return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[200]));
  }

  RenderStack(View view, List<Widget> childs) {
     print("BuildView build as center");
    // if (childs.length > 2) childs.insert(0, RenderNull(view));
    var height = null;
    view.styles.where((element) => element.hasHeight()).forEach((element) {
      height = element.height();
    });

    var backgroundColor = Colors.white;
    view.styles
        .where((element) => element.hasBackgroundColor())
        .forEach((element) {
      backgroundColor = element.backgroundColor();
    });

    // childs.insert(0, new Text("${height}"));
    return SingleChildScrollView(
        child: Container(
      width: 350,
      height: height,
      decoration: BoxDecoration(
          border: Border.all(width: 2.0, color: const Color(0xff00bcd4)),
          color: backgroundColor),
      child: Stack( 
        alignment: AlignmentDirectional.bottomStart,
        children: childs,
      ),
    ));
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
    if (renderCheck.IsForView(view)) {
      return RenderNull(view);
    }
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
      return RenderStack(view, childs);
    } else if (renderCheck.IsComponents(view)) {
      View component = Components.get(view.name);
      component.name = "view";
      return RenderView(component);
    } else if (renderCheck.IsRefresh(view)) {
      return RenderContainor(view, childs);
    } else if (renderCheck.IsList(view)) {
      return RenderContainor(view, childs);
    } else if (renderCheck.IsProgress(view)) {
      return RenderProgress(view);
    } else {
      return RenderNull(view);
    }
    return res;
  }
}
