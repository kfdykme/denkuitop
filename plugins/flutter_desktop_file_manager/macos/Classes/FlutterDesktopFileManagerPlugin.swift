import Cocoa
import FlutterMacOS

public class FlutterDesktopFileManagerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_desktop_file_manager", binaryMessenger: registrar.messenger)
    let instance = FlutterDesktopFileManagerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let userDefaults = UserDefaults.standard
    let bookmarkData = userDefaults.data(forKey: "basePath");
    if (bookmarkData != nil) {
      do {
        var isStale = false;
      let url = try URL(resolvingBookmarkData: bookmarkData!,options:NSURL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil,bookmarkDataIsStale:&isStale)
        url.startAccessingSecurityScopedResource()
      } catch let error {
        print("\(error)")
      }
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    case "onSelectFileManager":
      print("before onSelectFileManager")
      
      onSelectFileManager(result: result);
    case "updateDarkMode":
      let argv:[String:Any] = call.arguments as! [String: Any];
      var val =  argv["darkMode"];
      if (val == nil) {
        val = false;
      } else {
        val  = val as! Bool;
      }
      let darkMode = val;
      print("updateDarkMode",darkMode,argv)
      onUpdateDarkMode(darkMode: darkMode)
      result("");
    case "getDarkMode":
      let darkMode = onGetDarkMode();
      print("getDarkMode", darkMode)
      result(darkMode);
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onGetDarkMode() -> Bool {
    let userDefaults = UserDefaults.standard
    let darkMode = userDefaults.bool(forKey: "darkMode");
      print("onGetDarkMode", darkMode)
    return darkMode;
  }

  public func onUpdateDarkMode(darkMode: Any) {
     let userDefaults = UserDefaults.standard
     print("onUpdateDarkMode",darkMode);
    userDefaults.set(darkMode, forKey: "darkMode");
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

        // save as bookmark
        do {
          let url = openPanel.url!
          let bookmarkData = try url.bookmarkData(options:NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo:nil)
          let userDefaults = UserDefaults.standard
          userDefaults.set(bookmarkData, forKey: "basePath");
          userDefaults.set(selectedPath, forKey: "basePathURL");
        } catch let error {
          print("\(error)")
        }
        
        
        result(selectedPath);
      }
    })
  }
}
