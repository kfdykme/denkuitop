import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/ffi.dart';

typedef hello_world_func = Void Function();
typedef HelloWorld = void Function();

typedef lib_main_func = Void Function(Pointer<Int8> args, Int32 length);
typedef LibMain = void Function(Pointer<Int8> args, int length);
final lib = Platform.isMacOS
    ? DynamicLibrary.open('liblibdeno.dylib')
    : Platform.isWindows
        ? DynamicLibrary.open('libdeno.dll')
        : DynamicLibrary.open('libdeno.so');
final LibMain native_lib_main =
    lib.lookupFunction<lib_main_func, LibMain>("lib_main");
void innerIsolateLibMain(String args) {
  if (native_lib_main != null) {
    native_lib_main(args.toNativeUtf8().cast<Int8>(), args.length);
  } else {
    print("native_lib_main == null");
  }
}

class LibraryLoader {
  HelloWorld hello_rust;

  LibraryLoader() {
    // this.hello_rust =      this.lib.lookup<NativeFunction<Void Function()>>("hello_rust").asFunction();
  }

  void libMain(String args) {
    try {
      print("libMain ${args}");
      Isolate.spawn(innerIsolateLibMain, args);
    } catch (err) {
      print("${err}");
    }
  }
}
