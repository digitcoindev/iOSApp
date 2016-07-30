//
//  NotificationService.swift
//  jigit
//
//  Created by Lyubomir Dominik on 24.11.15.
//  Copyright © 2015 dominik. All rights reserved.
//

import UIKit

class NotificationManager
{    
    //MARK: Remout notification
    
    class func registerForNotification(application: UIApplication, remoutNotifications: Bool = false){
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings( settings )
        
        if remoutNotifications {
            application.registerForRemoteNotifications()
        }
    }
    
    class func didRegisterForRemoutNotification(deviceToken: NSData) {
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        let deviceTokenString: String? = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString(" ", withString: "" ) as String
    }
    
    class func didReceiveRemoutNotification(userInfo: [NSObject : AnyObject], identifier: String? = nil , responseInfo: [NSObject : AnyObject]? = nil) {
        
        guard let aps = userInfo["aps"] as? NSDictionary else {return}
        guard let badge = aps.valueForKey("badge") as? Int else {return}
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber - badge
    }
    
    private class func showNotificationBaner(title: String){
        var root = UIApplication.sharedApplication().windows.first?.rootViewController
        
        for ;; {
            if root?.presentedViewController != nil {
                root = root?.presentedViewController
            } else {
                break
            }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifire = "NotificationBaner"
        let controller :NotificationBaner =  storyboard.instantiateViewControllerWithIdentifier(identifire) as! NotificationBaner
        
        if let root = root {
            controller.view.frame.origin.y = -70
            controller.view.frame.size.height = 70
            root.view.addSubview(controller.view)
            controller.titleLabel.text = title
            controller.showBaner()
        }
    }
    
    //MARK: Local notification
    
    class func didReceiveLocalNotificaton(notification: UILocalNotification) {
        print(notification)
        showNotificationBaner(notification.alertBody!)
        UIApplication.sharedApplication().applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber - 1

    }
    
    class func sheduleLocalNotificationAfter(titile: String, body: String, interval: Double, userInfo: [NSObject : AnyObject]?) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = NSDate(timeIntervalSinceNow: interval)
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.alertTitle = titile
        localNotification.alertBody = body
        localNotification.userInfo = userInfo
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
}
