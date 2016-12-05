//
//  AppDelegate.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit
import AlamofireNetworkActivityIndicator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Application Properties
    
    var window: UIWindow?
    
    // MARK: - Application Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        if SettingsManager.sharedInstance.setupStatus() == false {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
            let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "AuthenticationPasswordCreationViewController")
            if (appDelegate.window != nil) {
                appDelegate.window!.rootViewController = rootViewController
            }
            
        } else {
            
            TimeManager.sharedInstance.synchronizeTime()
            
            if SettingsManager.sharedInstance.notificationUpdateInterval() == 0 {
                UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
            } else {
                UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(SettingsManager.sharedInstance.notificationUpdateInterval()))
            }
            
            NotificationManager.sharedInstance.registerForNotifications(application)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let authenticationPasswordValidationViewController = mainStoryboard.instantiateViewController(withIdentifier: "AuthenticationPasswordValidationViewController") as! AuthenticationPasswordValidationViewController
            
            if appDelegate.window != nil {
                appDelegate.window!.rootViewController = authenticationPasswordValidationViewController
                appDelegate.window!.makeKeyAndVisible()
            }
        }
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        TimeManager.sharedInstance.synchronizeTime()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if SettingsManager.sharedInstance.setupStatus() == true {
            
            let authenticationPasswordValidationViewController = mainStoryboard.instantiateViewController(withIdentifier: "AuthenticationPasswordValidationViewController") as! AuthenticationPasswordValidationViewController
            
            if appDelegate.window != nil {
                if let rootViewController = UIApplication.topViewController() {
                    if rootViewController is AuthenticationPasswordValidationViewController {
                        
                        appDelegate.window!.rootViewController = authenticationPasswordValidationViewController
                        
                    } else {
                        
                        rootViewController.present(authenticationPasswordValidationViewController, animated: false, completion: nil)
                    }
                }
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController is AuthenticationPasswordValidationViewController {
                
                rootViewController.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        NotificationManager.sharedInstance.didReceiveLocalNotificaton(notification)
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        NotificationManager.sharedInstance.performFetch(completionHandler)
    }
}
