

import 'package:denkuitop/common/ColorManager.dart';
import 'package:denkuitop/kfto/page/view/ViewBuilder.dart';
import 'package:flutter/material.dart';

class CommonDialogButtonOption {

    Function callback;
    String text;
    IconData icon;
    CommonDialogButtonOption({ text: String, callback: Function, IconData icon}) {
      this.text = text;
      this.callback = callback;
      this.icon = icon;
    }


}


class DenktuiDialog {
  
  static BuildContext _currentContexnt;

  static initContext (BuildContext context) {
    _currentContexnt = context;
  }
  static ShowDialog({Widget content, List<Widget> children}) {
    showDialog(
        context: _currentContexnt,
        builder: (context) {
          return AlertDialog(
            content: content,
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: children
              )
            ],
          );
        });
  }

  

  
  static ShowCommonDialog({ String contentTitle, List<CommonDialogButtonOption> options}) {

    List<Widget> views = [];

    options.forEach(((element) {
      views.add(ViewBuilder.BuildInLineMaterialButton(element.text,
            onPressFunc: () {
        Navigator.of(_currentContexnt).pop();
        element.callback();
      },
      color: ColorManager.highLightColor,
      icon: Icon(
        element.icon,
        color: ColorManager.highLightColor,
        size: ViewBuilder.size(2),
      )));
    }));
    
    ShowDialog(content: Container(
      child: Text(contentTitle),
    ), children: views);
  }
}