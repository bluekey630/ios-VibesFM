//
//  StringExtension.swift
//  Radio
//
//  Created by Admin on 11/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation

extension String {
    static func className(aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).componentsSeparatedByString(".").last!
    }
    
    func substring(from: Int) -> String {
        return self.substringFromIndex(self.startIndex.advancedBy(from))
    }
    
    var length: Int {
        return self.characters.count
    }
    
    var isEmailValid: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])", options: .CaseInsensitive)
            return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
    
    var isNameValid: Bool {
        let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z].*", options: NSRegularExpressionOptions())
        if regex.firstMatchInString(self, options: NSMatchingOptions(), range:NSMakeRange(0, self.characters.count)) != nil {
            return false
        } else {
            return true
        }
    }

    func convertToDate() -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        return dateFormatter.dateFromString(self)!
    }

    func converEmojiToUnicode() -> String {
        let data = self.dataUsingEncoding(NSNonLossyASCIIStringEncoding)
        let finalString = String.init(data: data!, encoding: NSUTF8StringEncoding)
        
        return finalString!
    }
    
    func covertUnicodeToEmoji() -> String {
        let updatedString = self.stringByReplacingOccurrencesOfString("\\\\", withString: "\\")
        let data = updatedString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        let finalString = String.init(data: data!, encoding: NSNonLossyASCIIStringEncoding)

        return finalString!
    }
}