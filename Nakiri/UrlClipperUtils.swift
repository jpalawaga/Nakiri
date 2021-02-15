import Foundation
import SwiftUI
import os.log

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
    if var components = URLComponents(string: url) {
        let queryParamsToRemove = getRemovableQueryParams(host: components.host)
        
        var preservedQueryParameters = [URLQueryItem]()
        if let queryItems = components.queryItems {
            for queryItem in queryItems {
                if (!queryParamsToRemove.contains(queryItem.name)) {
                    preservedQueryParameters.append(queryItem)
                }
            }
            components.queryItems = preservedQueryParameters
            return removeLastQuestion(url: components.string!)
        }
    }
    
    return removeLastQuestion(url: url)
}

/**
 * If the last character of a url is a ?, just chop it off.
 */
func removeLastQuestion(url: String) -> String {
    return url.hasSuffix("?") ? String(url.dropLast()) : url
}

/**
 * Truncates a url for display purposes.
 */
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

func getRemovableQueryParams(host: String?) -> [String] {
    let slicerDefinitions = NSDataAsset(name: "SlicerDefinitions")
    let jsonDecoder = JSONDecoder()
    let definitions = try! jsonDecoder.decode(SlicerDefinitions.self, from: slicerDefinitions!.data)
    let trimmedHost: String
    if (host != nil && host?.hasPrefix("www.") ?? false) {
        trimmedHost = String(host!.dropFirst(4))
    } else {
        trimmedHost = ""
    }
    
    var paramToReturn: [String] = []
    paramToReturn.append(contentsOf: definitions.query_parameters["global"] ?? [])
    paramToReturn.append(contentsOf: definitions.query_parameters[trimmedHost] ?? [])
    
    os_log("Found %d candidates for host %@", paramToReturn.count, trimmedHost)

    return paramToReturn
}
