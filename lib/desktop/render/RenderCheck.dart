import 'package:denkuitop/desktop/data/View.dart';
import 'package:denkuitop/desktop/render/Components.dart';

class RenderCheck {
  IsText(View view) {
    return view.name == "text";
  }

  IsContainor(View view) {
    return view.name == "template" ||
        view.name == "view" ||
        view.name == "div" ||
        IsList(view) ||
        _IsName(view, "block");
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
    print(
        "BuildView IsShow ${view.name} ${view.jsonParams["show"]} ${view.jsonParams["show"] == "false"}");
    return !(view.jsonParams["show"] == "false");
  }

  IsList(View view) {
    return _IsName(view, "list");
  }

  IsRefresh(View view) {
    return _IsName(view, "refresh");
  }

  _IsName(View view, String name) {
    return view.name == name;
  }

  bool IsComponents(View view) {
    return Components.has(view.name);
  }
}
