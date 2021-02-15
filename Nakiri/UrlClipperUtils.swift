import Foundation

public func cleanUrl(url: String) -> String {
    let trimmedURL = stripClickjackers(url: url)
    return removeUnnecessaryQueryParams(url: trimmedURL)
}

public func stripClickjackers(url: String) -> String {
    if let components = URLComponents(string: url) {
        if ((components.host?.hasSuffix("google.com")) != nil) {
            if (components.path == "/url") {
                let queryParams = convertQueryItemsToDict(input: components.queryItems)
                return queryParams["q"] ?? url
            }
        }

        if (((components.host?.hasSuffix("facebook.com")) != nil) && (components.path == "/l.php")) {
            let queryParams = convertQueryItemsToDict(input: components.queryItems)
            return queryParams["u"]?.removingPercentEncoding ?? url
        }
    }

    return url
}

func removeUnnecessaryQueryParams(url: String) -> String {
    let queryParamsToRemove = [
        // Universal?
        "u",
        "h",
        "utm_source",
        "utm_medium",
        "utm_campaign",
        "utm_term",
        "utm_content",
        "fbclid",

        // Twitter
        "src", "vertical","ref_src",

        // Google (Images)
        "rlz", "source", "sxsrf", "tbm", "sa", "ved", "biw", "bih",

        // Spotify
        "si",

        // Amazon
        "dchild", "keywords", "qid", "sr", "psc", "cv_ct_cx", "spLa", // Do we want do keep or delete keywords?
        "pd_rd_i", "pd_rd_r", "pd_rd_w", "pd_rd_wg", "pf_rd_p", "pf_rd_r",
        
        // tiktok - user_id and timestamp seem like they should probably be specific to tiktok.
        "_d", "sec_user_id", "share_item_id", "share_link_id", "timestamp", "tt_from", "u_code", "user_id"
    ]

    if var components = URLComponents(string: url) {
        var qps = [URLQueryItem]()
        if let queryItems = components.queryItems {
            for queryItem in queryItems {
                if (!queryParamsToRemove.contains(queryItem.name)) {
                    qps.append(queryItem)
                }
                print("\(String(describing: queryItem.name)): \(String(describing: queryItem.value))")
            }
            components.queryItems = qps
            return removeLastQuestion(url: components.string!)
        }
    }
    
    return removeLastQuestion(url: url)
}

func removeLastQuestion(url: String) -> String {
    return url.hasSuffix("?") ? String(url.dropLast()) : url
}

func friendlyTruncateUrl(url: String, desiredLength: Int = 40) -> String {
    if let regex = try? NSRegularExpression(pattern: "https:\\/\\/(www\\.)?", options: .caseInsensitive) {
        let mutableUrl = NSMutableString(string: url)
        regex.replaceMatches(in: mutableUrl, range: NSMakeRange(0, url.count), withTemplate: "")

        return String(mutableUrl.substring(to:min(desiredLength, mutableUrl.length)) + "...")
    }

    return url[url.startIndex..<url.index(url.startIndex, offsetBy: desiredLength)] + "..."
}

/**
 * Quick and dirty util to approximate whether or not if we copied a url or not.
 *
 * Might be improved with using the url class and etc but this is fine.
 */
func isUrlWithQueryParams(url: String) -> Bool {
    return url.starts(with: "http") && url.contains("?")
}