import Cocoa
import FlutterMacOS

public class FlutterDesktopFileManagerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_desktop_file_manager", binaryMessenger: registrar.messenger)
    let instance = FlutterDesktopFileManagerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    case "onSelectFileManager":
      print("before onSelectFileManager")
      
      onSelectFileManager(result: result);
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onSelectFileManager(result: @escaping FlutterResult) {
    print("onSelectFileManager");
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = false
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = true
    openPanel.canCreateDirectories = true
    // openPanel.canCreateDirectories = false
    // openPanel.title = title

    openPanel.begin(completionHandler: { (res) in 
      if (res == NSApplication.ModalResponse.OK) {
        let selectedPath = openPanel.url!.path
        result(selectedPath);
      }
    })
  }
}
