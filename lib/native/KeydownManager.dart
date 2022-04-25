
import 'dart:core';
import 'dart:ffi';

import 'package:denkuitop/native/LibraryLoader.dart';

void main() {
  
  KeydownManager.ins.RegisterHotKeyEvent("ctrl-s", () {
    print("save ");
  });
}

class KeydownManager {
  LibraryLoader lib = LibraryLoader.instance;

  Map<int, Function> callback_maps = new Map();

  static KeydownManager sInstance = null;
  static int sCallbackId = 0;

  static KeydownManager get ins {
    if (sInstance == null) {
      sInstance = KeydownManager();
      sInstance.init();
    }
    return sInstance;
  }

  static void onHotkeyCallback(int callback_id) {
    print("on onHotkeyCallback ${callback_id}");
    if (KeydownManager.ins.callback_maps.containsKey(callback_id)) {
      KeydownManager.ins.callback_maps[callback_id]();
    }
  }


  void init(){
    print("keydownmanager init");
    lib.libInitKeyDownCallback(Pointer.fromFunction(KeydownManager.onHotkeyCallback));
  }



  void RegisterHotKeyEvent(String hotkey, Function callback) { 
    int func_id = sCallbackId++;
    callback_maps[func_id] = callback;
    lib.libRegisterKeydown(hotkey, func_id);
  }
}