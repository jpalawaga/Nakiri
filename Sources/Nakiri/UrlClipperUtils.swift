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
        "u",
        "h",
        "utm_source",
        "utm_medium",
        "utm_campaign",
        "utm_term",
        "utm_content",
        "fbclid",
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
    if url.hasSuffix("?") {
        return String(url.dropLast())
    }
    return url
}

func friendlyTruncateUrl(url: String, desiredLength: Int = 40) -> String {
    if let regex = try? NSRegularExpression(pattern: "https:\\/\\/(www\\.)?", options: .caseInsensitive) {
        let mutableUrl = NSMutableString(string: url)
        regex.replaceMatches(in: mutableUrl, range: NSMakeRange(0, url.count), withTemplate: "")

        return String(mutableUrl.substring(to:min(desiredLength, mutableUrl.length)) + "...")
    }

    return url[url.startIndex..<url.index(url.startIndex, offsetBy: desiredLength)] + "..."
}
