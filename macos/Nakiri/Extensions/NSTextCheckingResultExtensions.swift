//
//  NSTextCheckingResultExtensions.swift
//  Nakiri
//
//  Created by James Palawaga on 2/27/21.
//

import Foundation

extension NSTextCheckingResult {
    func sequentialGroups(inputString:String) -> [String?] {
        return (0..<self.numberOfRanges).map {it -> String? in
            let range = Range(self.range(at: it), in: inputString)
            if (range != nil) {
                return String(inputString[range!])
            } else {
                return nil
            }
        }
    }
}
