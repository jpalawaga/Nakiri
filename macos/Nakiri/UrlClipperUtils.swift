import Foundation
import SwiftUI
import os.log

let remoteRulesUrl = "https://www.nakiri.app/engine/v1/rules.json"

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
    let ruleText = getRules()
    let jsonDecoder = JSONDecoder()
    let ruleContainer = try! jsonDecoder.decode(RuleContainer.self, from: ruleText)
    let trimmedHost: String
    if (host != nil && host?.hasPrefix("www.") ?? false) {
        trimmedHost = String(host!.dropFirst(4))
    } else {
        trimmedHost = ""
    }

    var paramToReturn: [String] = []
    let definitions = ruleContainer.rules.query_parameters
    paramToReturn.append(contentsOf: definitions["*"] ?? [])
    paramToReturn.append(contentsOf: definitions[trimmedHost] ?? [])

    os_log("Found %d candidates for host %@", paramToReturn.count, trimmedHost)

    return paramToReturn
}

func getClicktrackerDetails(host: String) -> QPClicktrackerDefinition? {
    let ruleText = getRules()
    let jsonDecoder = JSONDecoder()

    let rules = try! jsonDecoder.decode(
        RuleContainer.self,
        from: ruleText
    )
    let defns = rules.rules.clicktrackers_queryparam

    for clicktracker in defns {
        if (host.hasSuffix(clicktracker.key)) {
            return clicktracker.value
        }
    }

    return nil
}

func applicationSupportURLProvider() -> URL {
    let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let url = appSupportURL.appendingPathComponent(Bundle.main.bundleIdentifier!, isDirectory: true)
    var objCBoolTrue = ObjCBool(true)
    if (!FileManager.default.fileExists(atPath: url.path, isDirectory: &objCBoolTrue)) {
        os_log("Making directory %@", url.path)
        // TODO: If we can't create the directory, can we just return a null and fall back instead?
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
    }

    return url
}

func getRules() -> Data {
    let appSupportFolder = applicationSupportURLProvider()
    let slicerFile = appSupportFolder.appendingPathComponent("rules.json")

    if (FileManager.default.fileExists(atPath: slicerFile.path)) {
        return try! Data(contentsOf: slicerFile)
    }

    return NSDataAsset(name: "rules")!.data
}

func getRemoteDefinitions() {
    // @TODO: Once this becomes big enough we'll definitely want to cache locally using etags.
    // @TODO: We probably want to verify the signature of all of this.
    //https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_as_data

    let request = URLRequest(url: URL(string: remoteRulesUrl)!)
    let session = URLSession.shared
    let webtask = session.dataTask(with: request, completionHandler: handleDefinitionsResponse(incomingData:response:error:))
    webtask.resume()
}

func handleDefinitionsResponse(incomingData: Data?, response: URLResponse?, error: Error?) {
    if (error == nil && incomingData != nil) {
        let appSupportFolder = applicationSupportURLProvider()
        let ruleFile = appSupportFolder.appendingPathComponent("rules.json")
        os_log("Got definition file, writing to %@", ruleFile.path)
        try! incomingData!.write(to: ruleFile)
    } else {
        os_log("Got an error or empty response while retrieving the definitions.")
    }
}

class RuleContainer : Codable {
    public var rules: RuleDefinitions
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
class RuleDefinitions : Codable {
    public var query_parameters: [String: [String]]
    public var clicktrackers_queryparam: [String: QPClicktrackerDefinition]
}

class QPClicktrackerDefinition : Codable {
    public var path: String
    public var qp_real_url: String
}
