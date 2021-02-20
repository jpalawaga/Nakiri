//
//  Versioning.swift
//  Nakiri
//
//  Created by James Palawaga on 2/20/21.
//

import Foundation

class updateChecker {
    let callbackWhenUpdateAvailable: (() -> Void)
    init(callbackWhenUpdateAvailable: @escaping (() -> Void)) {
        self.callbackWhenUpdateAvailable = callbackWhenUpdateAvailable
    }

    /**
     * Entry point for the beginning of the check.
     *
     * Ultimately, the callback given at class instantiation will be called if an update is available.
     */
    func beginVersionCheck() {
        let request = URLRequest(url: URL(string: "https://api.github.com/repos/jpalawaga/nakiri/releases/latest")!)
        let session = URLSession.shared
        let webtask = session.dataTask(
            with: request,
            completionHandler: handleReleaseResponse(incomingData:response:error:)
        )
        webtask.resume()
    }

    private func handleReleaseResponse(incomingData: Data?, response: URLResponse?, error: Error?) {
        if (error == nil && incomingData != nil) {
            let decoder = JSONDecoder()
            let response = try? decoder.decode(ReleaseResponse.self, from: incomingData!)
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

            // @TODO: This will not do lol. Need to break it down by components.
            if (response?.tagName != version) {
                callbackWhenUpdateAvailable()
            }
        }
    }
}


/*
class SemVer {
    // I know that there are libraries that will do this for me.
    // But, in the interest of keeping filesize to a minimum, Imma implment it myself.
    // Not the best engineering practice but yOlOoooo.
    let versionString: String
    let major: Int
    let minor: Int
    let patch: Int
    init(versionString: String) {
        self.versionString = versionString

        let versionWithoutv = versionString.drop { $0 == "v" }
        let version, release = versionWithoutv.split(separator: "-")
        let arr = versionWithoutv.split(separator: ".")

        major = Int(arr[0])!
        minor = Int(arr[1])!
        patch = Int(arr[2])!
    }

}*/


/**
 * Class for representing github's response
 *
 * We're only decoding a single field for the time being.
 */
class ReleaseResponse : Codable {
    public var tagName: String

    public enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
    }
}
