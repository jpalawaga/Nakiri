import XCTest
import class Foundation.Bundle
@testable import Nakiri

final class NakiriTests: XCTestCase {
    
    func testStripClickJackers() throws {
        let googleClickjacker = "https://www.google.com/url?q=https://twitter.com/SenTedCruz/status/1304754228477472768&sa=D&source=hangouts&ust=1600110258819000&usg=AFQjCNGJVUiLTqJxCBvZSb64ob_rrFMDtA"
        
        let cleaned = stripClickjackers(url: googleClickjacker)
        XCTAssertEqual( "https://twitter.com/SenTedCruz/status/1304754228477472768", cleaned)
    }
    
    static var allTests = [
        ("testStripClickJackers", testStripClickJackers),
    ]
}
