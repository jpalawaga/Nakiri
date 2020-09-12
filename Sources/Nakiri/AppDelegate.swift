import Cocoa

/// Protocol defining the methods which delegate has/ can implement
protocol PasteboardWatcherDelegate {
    
    /// the method which is invoked on delegate when a new url of desired kind is copied
    /// - Parameter copiedUrl: the newly copied url of desired kind
    func newlyCopiedItem(copiedString: String?)
}

class AppDelegate: NSObject, NSApplicationDelegate, PasteboardWatcherDelegate {

  var statusBarItem: NSStatusItem!
  var counter: Int = 0
    
    func newlyCopiedItem(copiedString: String?) {
        let clipString = copiedString ?? ""
        
        if let clipUrl = removeUnnecessaryQueryParams(url: clipString) {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(clipUrl, forType: NSPasteboard.PasteboardType.string)
            statusBarItem.button?.title = "!!"
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

class PasteboardWatcher : NSObject {

    // assigning a pasteboard object
    private let pasteboard = NSPasteboard.general

    // to keep track of count of objects currently copied
    // also helps in determining if a new object is copied
    private var changeCount : Int

    // used to perform polling to identify if url with desired kind is copied
    private var timer: Timer?

    // the delegate which will be notified when desired link is copied
    var delegate: PasteboardWatcherDelegate?

    /// initializer which should be used to initialize object of this class
    /// - Parameter fileKinds: an array containing the desired file kinds
    override init() {
        // assigning current pasteboard changeCount so that it can be compared later to identify changes
        changeCount = pasteboard.changeCount

        super.init()
    }
    /// starts polling to identify if url with desired kind is copied
    /// - Note: uses an NSTimer for polling
    func startPolling () {
        // setup and start of timer
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: Selector("checkForChangesInPasteboard"), userInfo: nil, repeats: true)
    }

    /// method invoked continuously by timer
    /// - Note: To keep this method as private I referred this answer at stackoverflow - [Swift - NSTimer does not invoke a private func as selector](http://stackoverflow.com/a/30947182/217586)
    @objc private func checkForChangesInPasteboard() {
        // check if there is any new item copied
        // also check if kind of copied item is string
        
        if pasteboard.changeCount != changeCount {
            let copiedString = pasteboard.string(forType: NSPasteboard.PasteboardType.string)
            self.delegate?.newlyCopiedItem(copiedString: copiedString)
            
            // assign new change count to instance variable for later comparison
            changeCount = pasteboard.changeCount
        }
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
                print("\(queryItem.name): \(queryItem.value)")
            }
            components.queryItems = qps
            return components.string
        }
    }
    
    return url?.absoluteString
}
