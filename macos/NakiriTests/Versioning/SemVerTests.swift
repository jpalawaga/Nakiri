//
//  SemVerTests.swift
//  NakiriTests
//
//  Created by James Palawaga on 2/27/21.
//

import Foundation

import XCTest
import class Foundation.Bundle
@testable import Nakiri

final class SemVerTests: XCTestCase {

    func testBasic() throws {
        let versionAll = try! SemVer(versionString: "1.2.3-release1+build4")
        XCTAssertEqual(versionAll.major, 1)
        XCTAssertEqual(versionAll.minor, 2)
        XCTAssertEqual(versionAll.patch, 3)
        XCTAssertEqual(versionAll.prerelease, "release1")
        XCTAssertEqual(versionAll.build, "build4")

        // Also throw a V in there why not
        let versionNoRelease = try! SemVer(versionString: "v4.1.1+build-8abd3a")
        XCTAssertEqual(versionNoRelease.major, 4)
        XCTAssertEqual(versionNoRelease.minor, 1)
        XCTAssertEqual(versionNoRelease.patch, 1)
        XCTAssertEqual(versionNoRelease.prerelease, nil)
        XCTAssertEqual(versionNoRelease.build, "build-8abd3a")

        let versionNoBuild = try! SemVer(versionString: "V5.9.4-alpha2")
        XCTAssertEqual(versionNoBuild.major, 5)
        XCTAssertEqual(versionNoBuild.minor, 9)
        XCTAssertEqual(versionNoBuild.patch, 4)
        XCTAssertEqual(versionNoBuild.prerelease, "alpha2")
        XCTAssertEqual(versionNoBuild.build, nil)
    }

    func testMalformed() throws {
        // tbh idk if we even want this or not.
        XCTAssertNil(try? SemVer(versionString: "1.2"))
        XCTAssertNil(try? SemVer(versionString: "1-beta5"))
        XCTAssertNil(try? SemVer(versionString: "1.0.x"))
        XCTAssertNil(try? SemVer(versionString: "Hello world!"))
    }

    func testSemVerCompare() throws {
        let versionA = try! SemVer(versionString: "1.2.3")
        let versionB = try! SemVer(versionString: "1.2.4")
        let versionC = try! SemVer(versionString: "1.2.4-beta1")
        XCTAssertTrue(versionA < versionB)
        XCTAssertTrue(versionB > versionA)
        XCTAssertFalse(versionC > versionB)

        // uhhhh...
        XCTAssertTrue(versionC == versionB)
    }

    static var allTests = [
        ("testBasic", testBasic),
        ("testMalformed", testMalformed),
        ("testSemVerCompare", testSemVerCompare),
    ]
}
