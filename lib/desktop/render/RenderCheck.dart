import 'package:denkuitop/desktop/data/View.dart';
import 'package:denkuitop/desktop/render/Components.dart';

class RenderCheck {
  IsText(View view) {
    return _IsName(view, "text");
  }

  IsContainor(View view) {
    return _IsName(view, "template") ||
        _IsName(view, "view") ||
        _IsName(view, "div") ||
        IsList(view) ||
        _IsName(view, "block") ||
        _IsName(view, "list-item");
  }

  IsTabs(View view) {
    return _IsName(view, "tabs");
  }

  IsTabContent(View view) {
    return _IsName(view, "tab-content");
  }

  IsForView(View view) {
    return view.jsonParams.containsKey("for");
  }

  IsButton(View view) {
    return view.name == 'input' &&
        view.jsonParams["type"] != null &&
        _ValueEqual(view, "type", "button");
  }

  IsInput(View view) {
    return view.name == 'input' &&
        (!_HasValue(view, "type") ||
            _ValueEqual(view, "type", "text") ||
            _ValueEqual(view, "type", "password"));
  }

  IsImage(View view) {
    return _IsName(view, 'image');
  }

  IsProgress(View view) {
    return _IsName(view, "progress");
  }

  IsStack(View view) {
    return view.name == 'stack';
  }

  IsShow(View view) {
    print(
        "BuildView IsShow ${view.name} ${view.jsonParams["show"]} ${view.jsonParams["show"] == "false"}");
    return !(_ValueEqual(view, "show", "false"));
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

  _HasValue(View view, String key) {
    return view.jsonParams[key] != null;
  }

  _ValueEqual(View view, String key, String value) {
    return view.jsonParams[key] == value;
  }

  bool IsComponents(View view) {
    return Components.has(view.name);
  }
}
