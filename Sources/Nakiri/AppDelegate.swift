import Cocoa

public class AppDelegate: NSObject, NSApplicationDelegate, PasteboardWatcherDelegate {
    private var statusBarItem: NSStatusItem!
    private var revertButton: NSMenuItem?
    private var lastUrl = ""
    private let pasteboardWatcher = PasteboardWatcher()
    
    func newlyCopiedItem(copiedString: String) {
        lastUrl = copiedString
        let cleanedUrl = cleanUrl(url: copiedString)

        if (cleanedUrl.starts(with: "http")) {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(cleanedUrl, forType: NSPasteboard.PasteboardType.string)
            statusBarItem.button?.title = "🔪"
            revertButton?.title = "Revert \(friendlyTruncateUrl(url: cleanedUrl))"
            revertButton?.isHidden = false
        } else {
            hideButton()
        }
    }

    @objc func revert() {
        // We don't want to trigger the URL cleaning again.
        pasteboardWatcher.changeCount += 1

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(lastUrl, forType: NSPasteboard.PasteboardType.string)
        
        hideButton()
    }
    
    public func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)

        let statusBarMenu = NSMenu(title: "Nakiri Menu")
        statusBarItem.menu = statusBarMenu
        
        revertButton = statusBarMenu.addItem(
            withTitle: "Revert",
            action: #selector(AppDelegate.revert),
            keyEquivalent: ""
        )

        statusBarMenu.addItem(
          withTitle: "Quit",
          action: #selector(AppDelegate.quit),
          keyEquivalent: "")

        pasteboardWatcher.delegate = self
        pasteboardWatcher.startPolling()
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
