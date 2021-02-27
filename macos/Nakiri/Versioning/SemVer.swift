//
//  SemVer.swift
//  Nakiri
//
//  Created by James Palawaga on 2/27/21.
//

import Foundation

class SemVer {
    // I know that there are libraries that will do this for me.
    // But, in the interest of keeping filesize to a minimum, Imma implment it myself.
    // Not the best engineering practice but yOlOoooo.

    let semverRegex = try! NSRegularExpression(pattern: "^[vV]?([0-9]{1,4})\\.([0-9]{1,4})?\\.([0-9]{1,4})?-?([a-z0-9]+)?\\+?([a-z0-9\\-]+)?$")

    let versionString: String
    let major: Int
    let minor: Int
    let patch: Int
    let prerelease: String?
    let build: String?
    init(versionString: String) throws {
        self.versionString = versionString
        let result = semverRegex.matches(in:versionString, range:NSMakeRange(0, versionString.utf16.count))

        if (result.isEmpty) {
            throw NSError(domain: "com.nakiri", code: 1, userInfo: nil)
        }

        let groups = result[0].sequentialGroups(inputString: versionString)

        if (groups[1] == nil || groups[2] == nil || groups[3] == nil) {
            throw NSError(domain: "com.nakiri", code: 1, userInfo: nil)
        }

        major = Int(groups[1]!)!
        minor = Int(groups[2]!)!
        patch = Int(groups[3]!)!
        prerelease = groups[4]
        build = groups[5]
    }
}

extension SemVer: Equatable {
    static func >(left: SemVer, right: SemVer) -> Bool {
        // Compare first the major, then the minor, then the patch, exiting as soon as we possibly know the answer.
        if (left.major > right.major) {
            return true
        } else if (left.major < right.major) {
            return false
        }

        if (left.minor > right.minor) {
            return true
        } else if (left.minor < right.minor) {
            return false
        }

        if (left.patch > right.patch) {
            return true
        } else if (left.patch < right.patch) {
            return false
        }

        return false
    }

    static func <(left: SemVer, right: SemVer) -> Bool {
        return right > left
    }

    static func ==(left: SemVer, right: SemVer) -> Bool {
        return (left.major == right.major && left.minor == right.minor && left.patch == right.patch)
    }
}
