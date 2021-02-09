import Foundation
import Cocoa
import Nakiri

let configExist = FileManager.default.fileExists(atPath: Nakiri.PLIST_PATH.absoluteString)

if (!configExist) {
    try? """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Disabled</key>
    <false/>
    <key>Label</key>
    <string>Nakiri</string>
    <key>Program</key>
    <string>/System/Applications/Nakiri.app</string>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
""".write(to: Nakiri.PLIST_PATH, atomically: false, encoding: String.Encoding.utf8)
}

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
