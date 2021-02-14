import Cocoa

// @TODO: not the standard com.whatever format
public var PLIST_PATH =  FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/LaunchAgents/Nakiri.plist")

public var APPLICATION_PATH = "/Applications/Nakiri.app"

public class AppDelegate: NSObject, NSApplicationDelegate, PasteboardWatcherDelegate {
    private var statusBarItem: NSStatusItem!
    private var revertButton: NSMenuItem?
    private var onLaunchButton: NSMenuItem?
    private var reportButton: NSMenuItem?
    private var lastUrl = ""
    private let pasteboardWatcher = PasteboardWatcher()

    /**
     * Sets up the menu bar and starts polling
     */
    public func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)

        let statusBarMenu = NSMenu(title: "Nakiri Menu")
        statusBarItem.menu = statusBarMenu

        // Set up the "undo slice" button
        revertButton = statusBarMenu.addItem(
            withTitle: "Revert",
            action: #selector(AppDelegate.revert),
            keyEquivalent: ""
        )

        reportButton = statusBarMenu.addItem(
            withTitle: "Report improperly trimmed URL",
            action: #selector(AppDelegate.reportImproperlyTrimmedUri),
            keyEquivalent: ""
        )


        // Setup the "Launch on Startup" button (only shows if the app is installed)
        if (FileManager.default.fileExists(atPath: APPLICATION_PATH)) {
            onLaunchButton = statusBarMenu.addItem(withTitle: "Launch on Startup", action: #selector(AppDelegate.toggleLaunchOnStartup), keyEquivalent: "")
            onLaunchButton?.state = convertBoolToNSControlState(bool: currentLaunchdState())
        }

        statusBarMenu.addItem(
          withTitle: "Quit",
          action: #selector(AppDelegate.quit),
          keyEquivalent: "")

        pasteboardWatcher.delegate = self
        pasteboardWatcher.startPolling(interval: 1)
    }

    func newlyCopiedItem(copiedString: String) {
        if (!isUrlWithQueryParams(url: copiedString)) {
            lastUrl = ""
            hideButton()
            return
        }

        reportButton?.title = "Report improperly trimmed URL"
        reportButton?.isEnabled = true

        lastUrl = copiedString
        let cleanedUrl = cleanUrl(url: copiedString)

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(cleanedUrl, forType: NSPasteboard.PasteboardType.string)
        statusBarItem.button?.title = "🔪"

        if (lastUrl != cleanedUrl) {
            revertButton?.title = "Revert \(friendlyTruncateUrl(url: cleanedUrl))"
            revertButton?.isHidden = false
        } else {
            revertButton?.title = ""
            revertButton?.isHidden = true
        }
    }

    private func hideButton() {
        statusBarItem.button?.title = ""
    }
    
    // --- Menu Bar Funcs
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

    @objc func reportImproperlyTrimmedUri() {
        // @TODO: Check that the domain belongs who it says it belongs to.
        // i.e. this might not run forever and people shouldn't be able to register the domain + scoop
        var request = URLRequest(url: URL(string: "http://127.0.0.1:5000/report-uri")!)
        request.httpBody = lastUrl.data(using: .utf8)
        request.httpMethod = "POST"
        let session = URLSession.shared
        let webtask = session.dataTask(with: request)
        webtask.resume()

        reportButton?.title = "Reported submitted—thanks!"
        reportButton?.isEnabled = false
        statusBarItem.title = "☑️"
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

/**
 * Helper function to convert a boolean to an NSControlState i.e. true -> on, false -> off.
 */
func convertBoolToNSControlState(bool: Bool) -> NSControl.StateValue {
    return bool ? .on : .off
}
