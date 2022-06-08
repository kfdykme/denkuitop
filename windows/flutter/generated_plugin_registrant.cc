//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_desktop_cef_web/flutter_desktop_cef_web_plugin.h>
#include <native_hotkey/native_hotkey_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FlutterDesktopCefWebPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterDesktopCefWebPlugin"));
  NativeHotkeyPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("NativeHotkeyPlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
}
