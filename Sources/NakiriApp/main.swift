import Foundation
import Cocoa
import Nakiri
import Logging

let configExist = FileManager.default.fileExists(atPath: Nakiri.PLIST_PATH.absoluteString)
let applicationInstalled = FileManager.default.fileExists(atPath: Nakiri.APPLICATION_PATH)

if (applicationInstalled && !configExist) {
    let args: [String] = ["/usr/bin/open", Nakiri.APPLICATION_PATH]
    let launchAgent = LaunchAgent(Label: "Nakiri", Disabled: false, ProgramArguments: args, RunAtLoad: true)

    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml
    try! encoder.encode(launchAgent).write(to: Nakiri.PLIST_PATH)
}

let appFolder = Bundle.main.resourceURL

// 2) we need to create a logger, the label works similarly to a DispatchQueue label
LoggingSystem.bootstrap(StreamLogHandler.standardError)

let logger = Logger(label: "com.example.BestExampleApp.main")

// 3) we're now ready to use it
logger.error("Hello World!")

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
