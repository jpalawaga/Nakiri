import XCTest
import class Foundation.Bundle
@testable import Nakiri

final class NakiriTests: XCTestCase {
    
    func testStripClickJackers() throws {
        let googleClickjacker = "https://www.google.com/url?q=https://twitter.com/SenTedCruz/status/1304754228477472768&sa=D&source=hangouts&ust=1600110258819000&usg=AFQjCNGJVUiLTqJxCBvZSb64ob_rrFMDtA"
        
        let googleCleaned = stripClickjackers(url: googleClickjacker)
        XCTAssertEqual( "https://twitter.com/SenTedCruz/status/1304754228477472768", googleCleaned)
        
        let facebookClickjacker = "https://l.facebook.com/l.php?u=http%3A%2F%2Frc.ca%2FRgVFyd%3Ffbclid%3DIwAR3YbvOQ8Nz-1z7ZvCU8UIAl169iBUKMAtC1u29ElHVCI4LfZcICFjyZ0Fk&h=AT1GgT3MPQr0lRq6JZpkCdeLUySMR8OHZRp22v8EXDAZ86OTdAdp0sHpXXMXQjjqinurlStJsiXAXlJvSdIAGRY0BpWb2W5UUSxb8vBSKfjwVqyk26ja6sEH1BH0QZm33brER4hkbNkYfz8srgTqAoYQoH4iW-T2dd9b5Nfl0UKUwPU-XhLEK0lOZ0c2H_iPbPRv3uTA9eJzcg7svnwRK6w_pLMozClBDs8gNvKIe4hZFLJ2n9jo9YepZkfh-_-ihzN5hljsmLzSKGDgh8FpHSA_7Mu9LdZ-eKxxNHw-7SDiPD6qE9Se1YztI0mvsk-BhWXBtBEDwsMAswjL3-n-8ncv3Nl0vuKSZT0HZiDg9Ah2WKcKW97D3gBh2sJKTQvb7H3PFRI65ikjX0F5ZsAX9n_mtiSFW-ibVb5C47kMytU2X9mDQEiI3YhWWv9JoGQA0FzYtTAx08NOztIbJmjiB1zTimIEzkGlc4ybU1bzgn6PnliMKTUlEs-brTVn873dBlMRAC4yfksUVlG_dO3k-zdF-Vfw7IUqzoOexVHTBNFtAUyJ3S8NqB_bbY69lsseaqL3lY2A-zrLBJpNQysUmeVFWHSwhihKKe55mOoXZcHywNiHMoXZbP8fg9Xh02Dzl8ENgbNtKHd5s3CprB2DeBvsH8ckLGK-gYUSNMFNPuGOoaTH_B8EWMsb-Ao"
        let facebookCleaned = stripClickjackers(url: facebookClickjacker)
        XCTAssertEqual("http://rc.ca/RgVFyd?fbclid=IwAR3YbvOQ8Nz-1z7ZvCU8UIAl169iBUKMAtC1u29ElHVCI4LfZcICFjyZ0Fk", facebookCleaned)
        XCTAssertEqual("http://rc.ca/RgVFyd", removeUnnecessaryQueryParams(url: facebookCleaned))
        
    }
    
    static var allTests = [
        ("testStripClickJackers", testStripClickJackers),
    ]
}
