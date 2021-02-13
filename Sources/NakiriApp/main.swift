import Foundation
import Cocoa
import Nakiri

let configExist = FileManager.default.fileExists(atPath: Nakiri.PLIST_PATH.absoluteString)
let applicationInstalled = FileManager.default.fileExists(atPath: Nakiri.APPLICATION_PATH)

if (applicationInstalled && !configExist) {
    let args: [String] = ["/usr/bin/open", Nakiri.APPLICATION_PATH]
    let launchAgent = LaunchAgent(Label: "Nakiri", Disabled: false, ProgramArguments: args, RunAtLoad: true)

    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml
    try! encoder.encode(launchAgent).write(to: Nakiri.PLIST_PATH)
}

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
