import Cocoa

public var PLIST_PATH =  FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/LaunchAgents/Nakiri.plist")

public class AppDelegate: NSObject, NSApplicationDelegate, PasteboardWatcherDelegate {
    private var statusBarItem: NSStatusItem!
    private var revertButton: NSMenuItem?
    private var onLaunchButton: NSMenuItem?
    private var lastUrl = ""
    private let pasteboardWatcher = PasteboardWatcher()

    
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

        onLaunchButton = statusBarMenu.addItem(withTitle: "Launch on Startup", action: #selector(AppDelegate.toggleLaunchOnStartup), keyEquivalent: "")
        onLaunchButton?.state = convertBoolToNSControlState(bool: currentLaunchdState())

        statusBarMenu.addItem(
          withTitle: "Quit",
          action: #selector(AppDelegate.quit),
          keyEquivalent: "")

        pasteboardWatcher.delegate = self
        pasteboardWatcher.startPolling()
    }

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
    
    @objc func toggleLaunchOnStartup() {
        let currentState = try! PropertyListDecoder().decode(LaunchAgent.self, from: Data(contentsOf: PLIST_PATH))
        
        currentState.Disabled = !currentState.Disabled
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        try! encoder.encode(currentState).write(to: PLIST_PATH)

        // @TODO: Better with data binding... somehow...
        onLaunchButton?.state = convertBoolToNSControlState(bool: !currentState.Disabled)
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
    
    private func currentLaunchdState() -> Bool {
        let currentState = try! PropertyListDecoder().decode(LaunchAgent.self, from: Data(contentsOf: PLIST_PATH))

        return !currentState.Disabled
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

func convertBoolToNSControlState(bool: Bool) -> NSControl.StateValue {
    return bool ? .on : .off
}

public class LaunchAgent : Codable {
    public var Label: String
    public var Disabled: Bool
    public var Program: String
    public var RunAtLoad: Bool
}
