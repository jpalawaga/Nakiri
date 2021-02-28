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
            guard let response = try? decoder.decode(ReleaseResponse.self, from: incomingData!) else {
                return
            }

            guard let latestVersion = try? SemVer(versionString: response.tagName) else {
                return
            }

            let currentVersion = try! SemVer(
                versionString: (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!
            )

            if (latestVersion > currentVersion) {
                callbackWhenUpdateAvailable()
            }
        }
    }
}

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
