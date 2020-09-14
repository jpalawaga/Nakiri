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

func convertQueryItemsToDict(input: [URLQueryItem]?) -> [String:String] {
    let converted = input?.reduce(into: [String:String]()) {
        if ($1.value != nil) {
            $0[$1.name] = $1.value
        }
    } ?? [String:String]()
    return converted
}

public func stripClickjackers(url: String) -> String {
    if let components = URLComponents(string: url) {
        if ((components.host?.hasSuffix("google.com")) != nil) {
            if (components.path == "/url") {
                let queryParams = convertQueryItemsToDict(input: components.queryItems)
                return queryParams["q"] ?? url
            }
        }

        if (((components.host?.hasSuffix("facebook.com")) != nil) && (components.path == "/l.php")) {
            let queryParams = convertQueryItemsToDict(input: components.queryItems)
            return queryParams["u"]?.removingPercentEncoding ?? url
        }
    }

    return url
}

func removeUnnecessaryQueryParams(url: String) -> String {
    let queryParamsToRemove = [
        "u",
        "h",
        "utm_source",
        "utm_medium",
        "utm_campaign",
        "utm_term",
        "utm_content",
        "fbclid",
    ]

    if var components = URLComponents(string: url) {
        var qps = [URLQueryItem]()
        if let queryItems = components.queryItems {
            for queryItem in queryItems {
                if (!queryParamsToRemove.contains(queryItem.name)) {
                    qps.append(queryItem)
                }
                print("\(String(describing: queryItem.name)): \(String(describing: queryItem.value))")
            }
            components.queryItems = qps
            return removeLastQuestion(url: components.string!)
        }
    }
    
    return removeLastQuestion(url: url)
}

func removeLastQuestion(url: String) -> String {
    if url.hasSuffix("?") {
        return String(url.dropLast())
    }
    return url
}
