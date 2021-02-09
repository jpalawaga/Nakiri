import Foundation
import Cocoa
import Nakiri

let path = "/Users/james/Library/LaunchAgents/Nakiri2.plist"
let configExist = FileManager.default.fileExists(atPath: path)

if (!configExist) {
    try? """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>Nakiri</string>
    <key>Program</key>
    <string>/System/Applications/Nakiri.app</string>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
""".write(toFile:  path, atomically: false, encoding: String.Encoding.utf8)
}

//let ourList = FileManager.default.contents(atPath: "~/Library/LaunchAgents/Nakiri.plist")
//let plist = try? (PropertyListSerialization.propertyList(from: ourList, options: .mutableContainersAndLeaves, format: nil)) as? [String]

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
