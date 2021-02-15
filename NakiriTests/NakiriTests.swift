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

    func testCleanUrl() {
        let amazonTest = "https://www.amazon.com/Google-Pixel-4a-Unlocked-Smartphone/dp/B08CFSZLQ4/ref=sr_1_1_sspa?spLa=ZW5jcnlwdGVkUXVhbGlmaWVyPUExQTM1MVFEUlY3UTg4JmVuY3J5cHRlZElkPUEwMDAwMzMxWUtZSFozMDROWkpPJmVuY3J5cHRlZEFkSWQ9QTA5MDI5NzQ2QjBKSFZFSlpCSEQmd2lkZ2V0TmFtZT1zcF9hdGYmYWN0aW9uPWNsaWNrUmVkaXJlY3QmZG9Ob3RMb2dDbGljaz10cnVl"
        XCTAssertEqual(
            "https://www.amazon.com/Google-Pixel-4a-Unlocked-Smartphone/dp/B08CFSZLQ4/ref=sr_1_1_sspa",
            cleanUrl(url: amazonTest)
        )

        let amazonTest2 = "https://www.amazon.com/Style-Bungie-Adjustable-Bungies-Graphite/dp/B001OW7JW0/ref=sxts_sxwds-bia-wc-drs1_0?cv_ct_cx=office+chair&dchild=1&keywords=office+chair&pd_rd_i=B001OW7JW0&pd_rd_r=e2ee4f95-3b60-4010-87ea-e3914588dcc9&pd_rd_w=Q7pID&pd_rd_wg=y639j&pf_rd_p=f3f1f1cd-8368-48df-ac69-94019fb84e3f&pf_rd_r=00FM1VHM9QHM3SD9D4H6&psc=1&qid=1600120741&sr=1-1-f7123c3d-6c2e-4dbe-9d7a-6185fb77bc58"
        XCTAssertEqual(
            "https://www.amazon.com/Style-Bungie-Adjustable-Bungies-Graphite/dp/B001OW7JW0/ref=sxts_sxwds-bia-wc-drs1_0",
            cleanUrl(url: amazonTest2)
        )

        let googleImagesTest =  "https://www.google.com/search?q=battery+energy+density+over+time&rlz=1C5CHFA_enUS862US863&sxsrf=ALeKk01_-Azzjpwq_kGhpAoVVtLMXyummw:1599768483440&source=lnms&tbm=isch&sa=X&ved=2ahUKEwj4kLaBst_rAhXslXIEHd7SDggQ_AUoAXoECA0QAw&biw=1680&bih=822#imgrc=BvCfoMaIMvFsKM"
        XCTAssertEqual(
            "https://www.google.com/search?q=battery+energy+density+over+time#imgrc=BvCfoMaIMvFsKM",
            cleanUrl(url: googleImagesTest)
        )

        let spotifyTest = "https://open.spotify.com/track/4uLU6hMCjMI75M1A2tKUQC?si=Sjc4fsOYRv6Wfl5LjIsqig"
        XCTAssertEqual(
            "https://open.spotify.com/track/4uLU6hMCjMI75M1A2tKUQC",
            cleanUrl(url: spotifyTest)
        )
    }

    static var allTests = [
        ("testStripClickJackers", testStripClickJackers),
        ("testCleanUrl", testCleanUrl),
    ]
}
