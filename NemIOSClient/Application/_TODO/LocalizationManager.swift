//
//  LocalizationManager.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 25.12.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class LocalizationManager {
    fileprivate static var bundle :Bundle? = nil
    
    class func setLanguage(_ language :String) {
        var languageId = language
        
        switch language {
        case "LANGUAGE_JAPANESE".localized():
            languageId = "ja"
        case "LANGUAGE_INDONESIAN".localized():
            languageId = "id-ID"
        case "LANGUAGE_ENGLISH".localized():
            languageId = "en"
        case "LANGUAGE_LITHUANIAN".localized():
            languageId = "lt"
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
        
        guard let path = Bundle.main.path(forResource: languageId, ofType: "lproj") else {
            bundle = Bundle.main
            return
        }
        
        bundle = Bundle(path: path) ?? Bundle.main
    }
    
    class func localizedSting(_ key :String, defaultValue: String? = nil) -> String? {
        
        if let _bundle = bundle {
            return _bundle.localizedString(forKey: key, value: nil, table: nil) ?? defaultValue
        } else {
            return NSLocalizedString(key, comment: defaultValue ?? key)
        }
    }
}
