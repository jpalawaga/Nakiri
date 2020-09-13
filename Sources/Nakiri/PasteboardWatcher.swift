import Foundation
import Cocoa

// Based on https://stackoverflow.com/a/30951590
class PasteboardWatcher : NSObject {

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
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.checkForChangesInPasteboard), userInfo: nil, repeats: true)
    }

    /// method invoked continuously by timer
    /// - Note: To keep this method as private I referred this answer at stackoverflow - [Swift - NSTimer does not invoke a private func as selector](http://stackoverflow.com/a/30947182/217586)
    @objc private func checkForChangesInPasteboard() {
        if pasteboard.changeCount != changeCount {
            let copiedString = pasteboard.string(forType: NSPasteboard.PasteboardType.string) ?? ""
            self.delegate?.newlyCopiedItem(copiedString: copiedString)

            // assign new change count to instance variable for later comparison
            changeCount = pasteboard.changeCount
        }
    }
}

/// Protocol defining the methods which delegate has/ can implement
protocol PasteboardWatcherDelegate {
    
    /// the method which is invoked on delegate when a new url of desired kind is copied
    /// - Parameter copiedUrl: the newly copied url of desired kind
    func newlyCopiedItem(copiedString: String)
}
