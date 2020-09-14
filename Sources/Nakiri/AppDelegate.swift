import Cocoa

public class AppDelegate: NSObject, NSApplicationDelegate, PasteboardWatcherDelegate {

    var statusBarItem: NSStatusItem!
    var revertButton: NSMenuItem?
    var lastUrl = ""
    var counter: Int = 0
    var recentlyReverted = false
    
    func newlyCopiedItem(copiedString: String) {
        if recentlyReverted {
            recentlyReverted = false
            return
        }
        
        lastUrl = copiedString
        var trimmedURL = stripClickjackers(url: copiedString)
        trimmedURL = removeUnnecessaryQueryParams(url: trimmedURL) 

        if (trimmedURL.starts(with: "http")) {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(trimmedURL, forType: NSPasteboard.PasteboardType.string)
            statusBarItem.button?.title = "🔪"
            
            if (revertButton != nil) {
                statusBarItem.menu?.removeItem(revertButton!)
            }
            revertButton = statusBarItem.menu?.addItem(
                withTitle: "Revert \(trimmedURL)",
                action: #selector(AppDelegate.revert),
                keyEquivalent: "")
            
        } else {
            statusBarItem.button?.title = ""
        }
    }

    @objc func revert() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(lastUrl, forType: NSPasteboard.PasteboardType.string)
        statusBarItem.button?.title = ""
        if (revertButton != nil) {
            statusBarItem.menu?.removeItem(revertButton!)
        }
        
        recentlyReverted = true
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
