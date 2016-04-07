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
        case "LANGUAGE_JAPANESE".localized():
            languageId = "ja"
        case "LANGUAGE_INDONESIAN".localized():
            languageId = "id-ID"
        case "LANGUAGE_ENGLISH".localized():
            languageId = "en"
        case "LANGUAGE_LITHUANIAN".localized():
            languageId = "It"
        case "LANGUAGE_CHINESE_SIMPLIFIED".localized():
            languageId = "zh-Hans"
        case "LANGUAGE_DUTCH".localized():
            languageId = "nl"
        case "LANGUAGE_PORTUGUESE".localized():
            languageId = "pt"
        case "LANGUAGE_CROATIAN".localized():
            languageId = "hr"
        case "LANGUAGE_FRENCH".localized():
            languageId = "fr"
        case "LANGUAGE_POLISH".localized():
            languageId = "pl"
        case "LANGUAGE_FINNISH".localized():
            languageId = "fi"
        case "LANGUAGE_SPANISH".localized():
            languageId = "es"
        case "LANGUAGE_GERMAN".localized() :
            languageId = "de"
        case "LANGUAGE_KOREAN".localized() :
            languageId = "ko"
        case "LANGUAGE_ITALIAN".localized() :
            languageId = "it-IT"
        case "Debug" :
            languageId = "Base"
        default :
            bundle = nil
            return
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
