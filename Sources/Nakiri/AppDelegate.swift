import Cocoa

public class AppDelegate: NSObject, NSApplicationDelegate, PasteboardWatcherDelegate {

    var statusBarItem: NSStatusItem!
    var counter: Int = 0
    
    func newlyCopiedItem(copiedString: String) {
        var trimmedURL = stripClickjackers(url: copiedString)
        trimmedURL = removeUnnecessaryQueryParams(url: trimmedURL) 

        if (trimmedURL.starts(with: "http")) {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(trimmedURL, forType: NSPasteboard.PasteboardType.string)
            statusBarItem.button?.title = "🔪"
        } else {
            statusBarItem.button?.title = ""
        }
    }

    public func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)

        let statusBarMenu = NSMenu(title: "Nakiri Menu")
        statusBarItem.menu = statusBarMenu

        statusBarMenu.addItem(
          withTitle: "Quit",
          action: #selector(AppDelegate.quit),
          keyEquivalent: "")

        let test = PasteboardWatcher()
        test.delegate = self
        test.startPolling()
    }
    
    @objc func quit() {
    NSApplication.shared.terminate(self)
    }
}

func convertQueryItemsToDict(input: [URLQueryItem]?) -> [String:String] {
    let converted = input?.reduce(into: [String:String]()) {
        if ($1.value != nil) {
            $0[$1.name] = $1.value
        }
    } ?? [String:String]()
    return converted
}
