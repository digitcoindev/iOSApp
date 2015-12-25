//
//  LocalizationManager.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 25.12.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class LocalizationManager {
    private static var bundle :NSBundle? = nil
    
    class func setLanguage(language :String) {
        var languageId = language
        switch language {
        case "Japanese" :
            languageId = "ja"
        case "Ukrainian" :
            languageId = "uk"
        case "Russian" :
            languageId = "ru"
        case "Korean" :
            languageId = "ko"
        case "English", "Base":
            languageId = "Base"
        case "c":
            bundle = nil
            return
        default :
            break
        }
        
        guard let path = NSBundle.mainBundle().pathForResource(languageId, ofType: "lproj") else {
            bundle = NSBundle.mainBundle()
            return
        }
        
        bundle = NSBundle(path: path) ?? NSBundle.mainBundle()
    }
    
    class func localizedSting(key :String, defaultValue: String? = nil) -> String? {
        
        if let _bundle = bundle {
            return _bundle.localizedStringForKey(key, value: nil, table: nil) ?? defaultValue
        } else {
            return NSLocalizedString(key, comment: defaultValue ?? key)
        }
    }
}
