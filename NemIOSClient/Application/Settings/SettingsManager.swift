//
//  SettingsManager.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import Foundation

/// The manager responsible for all tasks regarding application settings.
open class SettingsManager {
    
    // MARK: - Manager Properties
    
    /// The singleton for the settings manager.
    open static let sharedInstance = SettingsManager()
    
    /// The language bundle.
    private var bundle: Bundle?
    
    /// Available application languages.
    public enum ApplicationLanguage: String {
        case automatic = "automatic"
        case german = "de"
        case english = "en"
        case spanish = "es"
        case finnish = "fi"
        case french = "fr"
        case croatian = "hr"
        case indonesian = "id-ID"
        case italian = "it-IT"
        case japanese = "ja"
        case korean = "ko"
        case lithuanian = "lt"
        case dutch = "nl"
        case polish = "pl"
        case portuguese = "pt"
        case chineseSimplified = "zh-Hans"
    }
    
    // MARK: - Public Manager Methods

    /**
        Sets the active language for the application.
     
        - Parameter applicationLanguage: The application language which should get set for the application.
     */
    open func setApplicationLanguage(applicationLanguage: ApplicationLanguage) {
        
        let userDefaults = UserDefaults.standard
        var applicationLanguageIdentifier = String()
        
        if applicationLanguage == .automatic {
            userDefaults.set(nil, forKey: "applicationLanguage")
            bundle = nil
            return
        }
        
        applicationLanguageIdentifier = applicationLanguage.rawValue
        
        userDefaults.set(applicationLanguageIdentifier, forKey: "applicationLanguage")
        
        guard let bundlePath = Bundle.main.path(forResource: applicationLanguageIdentifier, ofType: "lproj") else {
            bundle = Bundle.main
            return
        }
        
        bundle = Bundle(path: bundlePath) ?? Bundle.main
    }
    
    /**
        Gets and returns the active application language.
     
        - Returns: The currently active application language.
     */
    open func applicationLanguage() -> ApplicationLanguage {
        
        let userDefaults = UserDefaults.standard
        let applicationLanguageIdentifier = userDefaults.object(forKey: "applicationLanguage") as? String ?? String()
        let applicationLanguage = ApplicationLanguage(rawValue: applicationLanguageIdentifier) ?? ApplicationLanguage.automatic

        return applicationLanguage
    }
    
    /**
 
     */
    open func localizedSting(_ key: String, defaultValue: String? = nil) -> String? {
        
        if let bundle = bundle {
            return bundle.localizedString(forKey: key, value: nil, table: nil) 
        } else {
            return NSLocalizedString(key, comment: defaultValue ?? key)
        }
    }
}
