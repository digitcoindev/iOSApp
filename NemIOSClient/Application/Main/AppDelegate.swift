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
        
//        SettingsManager.sharedInstance.createDefaultServers { (result) in
//            print("done")
//            
//            TimeManager.sharedInstance.synchronizeTime()
//        }
        
        if SettingsManager.sharedInstance.notificationUpdateInterval() == 0 {
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
        } else {
            UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(SettingsManager.sharedInstance.notificationUpdateInterval()))
        }
        
        NotificationManager.sharedInstance.registerForNotifications(application)
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        TimeManager.sharedInstance.synchronizeTime()
        
        //        if State.currentVC == SegueToPasswordValidation {return}
        //
        //        var root = UIApplication.sharedApplication().windows.first?.rootViewController
        //
        //        for ;; {
        //            if root!.presentedViewController != nil {
        //                root = root!.presentedViewController as! AbstractViewController
        //            } else {
        //                break
        //            }
        //        }
        //
        //        State.nextVC = State.currentVC ?? SegueToLoginVC
        //
        //        if root != nil  {
        //            root?.performSegueWithIdentifier(SegueToPasswordValidation, sender: self)
        //        }
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        NotificationManager.sharedInstance.didReceiveLocalNotificaton(notification)
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        NotificationManager.sharedInstance.performFetch(completionHandler)
    }
}
