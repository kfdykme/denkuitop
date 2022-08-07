import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/ffi.dart';

// libdeno
typedef lib_main_func = Void Function(Pointer<Int8> args, Int32 length);
typedef LibMain = void Function(Pointer<Int8> args, int length);
final libdeno = Platform.isMacOS
    ? DynamicLibrary.open('liblibdeno.dylib')
    : Platform.isWindows
        ? DynamicLibrary.open('libdeno.dll')
        : DynamicLibrary.open('libdeno.so');

final LibMain native_lib_main =
    libdeno.lookupFunction<lib_main_func, LibMain>("lib_main");

// libcreatelink
final libcreatelink = Platform.isMacOS 
    ? DynamicLibrary.open('createlink.dylib')
    : Platform.isWindows
        ? DynamicLibrary.open('libdeno.dll')
        : DynamicLibrary.open('libdeno.so');

typedef create_symlink_func = Void Function(Pointer<Int8> source, Pointer<Int8> linkfile);

final native_create_symlink_func = libcreatelink.lookupFunction<
  Void Function(Pointer<Int8> source, Pointer<Int8> link),
  void Function(Pointer<Int8> source, Pointer<Int8> link)
>("create_symlink");

// libkeydown
typedef lib_invoke_callback_function_type = Void Function(Int8 value);
// typedef lib_invoke_func = Void Function(Pointer<NativeFunction<lib_invoke_callback_function_type>> func);
// typedef LibInvokeCallback = void Function(Pointer<NativeFunction<lib_invoke_callback_function_type>> func);

final libkeydown = Platform.isMacOS
    ? DynamicLibrary.open('liblibkeydown.dylib')
    : Platform.isWindows
        ? DynamicLibrary.open('libkeydown.dll')
        : DynamicLibrary.open('libkeydown.so');

final native_lib_init_invoke_callback =
    libkeydown.lookupFunction<
            Void Function(
                Pointer<NativeFunction<lib_invoke_callback_function_type>>),
            void Function(
                Pointer<NativeFunction<lib_invoke_callback_function_type>>)>(
        "init_invoke_callback");

final native_lib_registry_hotkey = 
  libkeydown.lookupFunction<
  Void Function(Pointer<Int8> key, Int32 callback_id),
  void Function(Pointer<Int8> key, int callback_id)>("register_key");

void innerIsolateLibMain(String args) {
  if (native_lib_main != null) {
    native_lib_main(args.toNativeUtf8().cast<Int8>(), args.length);
  } else {
    print("native_lib_main == null");
  }
}

class LibraryLoader {
  LibraryLoader() {
    // this.hello_rust =      this.lib.lookup<NativeFunction<Void Function()>>("hello_rust").asFunction();
  }

  static LibraryLoader _sInstance = null;

  static LibraryLoader get instance {
    if (_sInstance == null) {
      _sInstance = LibraryLoader();
    }
    return _sInstance;
  }

  void libMain(String args) {
    try {
      print("libMain ${args}");
      Isolate.spawn(innerIsolateLibMain, args);
    } catch (err) {
      print("${err}");
    }
  }

  void libInitKeyDownCallback(
      Pointer<NativeFunction<lib_invoke_callback_function_type>> callback) {
    if (native_lib_init_invoke_callback != null) {
      native_lib_init_invoke_callback(callback); 
    } else {
      print("lib_invoke_func == null");
    }
  }

  void libRegisterKeydown(String key, int func_id) {
    if (native_lib_registry_hotkey != null) {
      native_lib_registry_hotkey(key.toNativeUtf8().cast<Int8>(), func_id);
    } else {
      print("native_lib_main == null");
    }
  }

  void libCreateLink(String source, String linkFile) {
    if (native_create_symlink_func != null) {
      native_create_symlink_func(source.toNativeUtf8().cast<Int8>(), linkFile.toNativeUtf8().cast<Int8>());
    } else {
      print("native create symlink func is null");
    }
  }
}
