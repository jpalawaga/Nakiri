import Foundation
import SwiftUI
import os.log

public func cleanUrl(url: String) -> String {
    let trimmedURL = stripClicktrackers(url: url)
    return removeUnnecessaryQueryParams(url: trimmedURL)
}

public func stripClicktrackers(url: String) -> String {
    if let components = URLComponents(string: url) {
        if (components.host == nil) {
            return url
        }

        let clicktrackerDetails = getClicktrackerDetails(host: components.host!)
        if (clicktrackerDetails == nil) {
            return url
        }

        // Dealing with a host that is known to clicktrack--check the path.
        if (components.path == clicktrackerDetails!.path) {
            let queryParams = convertQueryItemsToDict(input: components.queryItems)
            return queryParams[clicktrackerDetails!.qp_real_url] ?? url
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

/**
 * Reads the defintion file and returns a list of candidate query parameters to remove.
 *
 * FIXME: Right now the definitions almost certainly could be cached rather than read from disk every time.
 * Also: the host stuff is jank AF. Might want to implement maybe a trie or some other spell-checking tech.
 */
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

func getClicktrackerDetails(host: String) -> QPClicktrackerDefinition? {
    let slicerDefinitions = NSDataAsset(name: "SlicerDefinitions")
    let jsonDecoder = JSONDecoder()

    let clicktrackers = try! jsonDecoder.decode(
        SlicerDefinitions.self,
        from: slicerDefinitions!.data
    )
    let defns = clicktrackers.clicktrackers_queryparam

    for clicktracker in defns {
        if (host.hasSuffix(clicktracker.key)) {
            return clicktracker.value
        }
    }

    return nil
}

/**
 * Sort of a weird json definition. Basically two top-level keys:
 *  -  "query_parameters" which contains a dictionary that stores `host: [list, of, params, to, remove]`
 *  - "hosts" (TBD) that stores contains strategies for removing clicktrackers
 *  Because a lot of these are intentionally amorphous, the definitions are a little weird.
 *
 * As a thought, this could be changed to be well-formatted like {"host": google, "query_params": []}, but it just involves
 * more transformation, and I don't see an apparent benefit just yet.
 */
class SlicerDefinitions : Codable {
    public var query_parameters: [String: [String]]
    public var clicktrackers_queryparam: [String: QPClicktrackerDefinition]
}

class QPClicktrackerDefinition : Codable {
    public var path: String
    public var qp_real_url: String
}
