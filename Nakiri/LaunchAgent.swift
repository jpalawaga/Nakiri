//
//  LaunchAgent.swift
//
//
//  Created by James Palawaga on 2/12/21.
//
//  Classes and files to assist with managing our LaunchAgent state.

import Foundation

/**
 * Data class used to encode and decode our plist launchd configuration.
 */
public class LaunchAgent : Codable {
    public var Label: String
    public var Disabled: Bool
    public var ProgramArguments: [String]
    public var RunAtLoad: Bool
    
    public init(Label: String, Disabled: Bool, ProgramArguments: [String], RunAtLoad: Bool) {
        self.Label = Label
        self.Disabled = Disabled
        self.ProgramArguments = ProgramArguments
        self.RunAtLoad = RunAtLoad
    }
}


/**
 * Helper function to retrieve whether or not if we are enabled for launch on startup.
 */
func currentLaunchdState() -> Bool {
    let currentState = try! PropertyListDecoder().decode(LaunchAgent.self, from: Data(contentsOf: PLIST_PATH))

    return !currentState.Disabled
}
