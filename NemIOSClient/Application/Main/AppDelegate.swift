//
//  AppDelegate.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        NotificationManager.registerForNotification(application)
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
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
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        NotificationManager.didReceiveLocalNotificaton(notification)
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        FetchManager().update(completionHandler)
    }
}
