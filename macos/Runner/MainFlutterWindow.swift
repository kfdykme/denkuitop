import Cocoa
import FlutterMacOS
import flutter_desktop_cef_web

class MainFlutterWindow: NSWindow, NSWindowDelegate {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    FlutterDesktopCefWebPlugin.window = self
    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
  }

  public  func windowWillResize(
    _ sender: NSWindow,
    to frameSize: NSSize
  ) -> NSSize {
      print("windowWillResize")
      print(frameSize);
      FlutterDesktopCefWebPlugin.OnResize(delay: true)
    return frameSize
  }

    
    func windowDidChangeScreen(_ notification: Notification) {
        
//        FlutterDesktopCefWebPlugin.OnResize()
    }
    
    func windowDidEndLiveResize(_ notification: Notification) {
//        FlutterDesktopCefWebPlugin.OnResize()
    
    }
    
    func windowDidEnterFullScreen(_ notification: Notification) {
        
//        FlutterDesktopCefWebPlugin.OnResize()
    }

    func windowDidExitFullScreen(_ notification: Notification) {
        
//        FlutterDesktopCefWebPlugin.OnResize()
    }
    
  func windowDidResize(_ notification: Notification) {
    print("windowDidResize")
    
    FlutterDesktopCefWebPlugin.OnResize()
  }
}
