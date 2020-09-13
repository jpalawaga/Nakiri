import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, PasteboardWatcherDelegate {

  var statusBarItem: NSStatusItem!
  var counter: Int = 0
    
    func newlyCopiedItem(copiedString: String) {
        let trimmedURL = removeUnnecessaryQueryParams(url: copiedString) ?? ""
        if (trimmedURL.starts(with: "http")) {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(trimmedURL, forType: NSPasteboard.PasteboardType.string)
            statusBarItem.button?.title = "🔪"
        } else {
            statusBarItem.button?.title = ""
        }
    }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let statusBar = NSStatusBar.system
    statusBarItem = statusBar.statusItem(
      withLength: NSStatusItem.variableLength)

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


func removeUnnecessaryQueryParams(url: String) -> String? {
    let queryParamsToRemove = [
        "u",
        "h",
        "utm_source",
        "utm_medium",
        "utm_campaign",
        "utm_term",
        "utm_content"
    ]
    let url = URL(string: url)

    if var components = URLComponents(url: url!, resolvingAgainstBaseURL: false) {
        var qps = [URLQueryItem]()
        if let queryItems = components.queryItems {
            for queryItem in queryItems {
                if (!queryParamsToRemove.contains(queryItem.name)) {
                    qps.append(queryItem)
                }
                print("\(String(describing: queryItem.name)): \(String(describing: queryItem.value))")
            }
            components.queryItems = qps
            return components.string
        }
    }
    
    return url?.absoluteString
}
