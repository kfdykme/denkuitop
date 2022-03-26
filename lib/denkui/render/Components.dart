import 'dart:collection';

import 'package:denkuitop/denkui/data/View.dart';

class Components {
  static Map<String, View> _components = new HashMap();
  static register(View view) {
    _components[view.name] = view;
  }

  static has(String name) {
    return get(name) != null;
  }

  static get(String name) {
    return _components[name];
  }
}
