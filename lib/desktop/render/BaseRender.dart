import 'package:denkuitop/desktop/data/View.dart';
import 'package:denkuitop/desktop/ipc/IpcClient.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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

  RenderInput(View view) {
    return TextField(
      obscureText: view.jsonParams["type"] == "password",
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: view.jsonParams["placeholder"],
      ),
    );
  }

  RenderText(View view) {
    print("BuidView build as text: ${view.name} -> ${view.content}");
    return Text(view.content);
  }

  RenderButton(View view) {
    return RaisedButton(
        onPressed: () {
          ipc?.send("invoke:${view.jsonParams["onclick"]}");
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: childs,
      ),
    );
  }

  RenderView(View view) {
    print("BuildView form ${view.name}");
    List<Widget> childs = [];

    view.childs.forEach((element) {
      childs.add(RenderView(element));
    });
    var res;
    if (IsText(view)) {
      return RenderText(view);
    } else if (IsContainor(view)) {
      return RenderContainor(view, childs);
    } else if (IsButton(view)) {
      return RenderButton(view);
    } else if (IsInput(view)) {
      return RenderInput(view);
    } else {
      return RenderNull(view);
    }
    return res;
  }
}
