import Cocoa

public class AppDelegate: NSObject, NSApplicationDelegate, PasteboardWatcherDelegate {

    var statusBarItem: NSStatusItem!
    var revertButton: NSMenuItem?
    var lastUrl = ""
    var counter: Int = 0
    let test = PasteboardWatcher()
    
    func newlyCopiedItem(copiedString: String) {
        lastUrl = copiedString
        var trimmedURL = stripClickjackers(url: copiedString)
        trimmedURL = removeUnnecessaryQueryParams(url: trimmedURL) 

        if (trimmedURL.starts(with: "http")) {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(trimmedURL, forType: NSPasteboard.PasteboardType.string)
            statusBarItem.button?.title = "🔪"
            revertButton?.title = "Revert \(trimmedURL)"
            revertButton?.isHidden = false
        } else {
            hideButton()
        }
    }

    @objc func revert() {
        // We don't want to trigger the URL cleaning again.
        test.changeCount += 1

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(lastUrl, forType: NSPasteboard.PasteboardType.string)
        
        hideButton()
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
        
        revertButton = statusBarMenu.addItem(
            withTitle: "Revert",
            action: #selector(AppDelegate.revert),
            keyEquivalent: ""
        )

        test.delegate = self
        test.startPolling()
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
    
    private func hideButton() {
        statusBarItem.button?.title = ""
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
