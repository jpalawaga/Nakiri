import Foundation

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
        "src", "vertical",

        // Google (Images)
        "rlz", "source", "sxsrf", "tbm", "sa", "ved", "biw", "bih",

        // Spotify
        "si",

        // Amazon
        "dchild", "keywords", "qid", "sr", "psc", "cv_ct_cx", // Do we want do keep or delete keywords?
        "pd_rd_i", "pd_rd_r", "pd_rd_w", "pd_rd_wg", "pf_rd_p", "pf_rd_r",
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
