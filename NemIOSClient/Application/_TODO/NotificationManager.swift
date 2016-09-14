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
    
    class func registerForNotification(_ application: UIApplication, remoutNotifications: Bool = false){
        UIApplication.shared.applicationIconBadgeNumber = 0
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings( settings )
        
        if remoutNotifications {
            application.registerForRemoteNotifications()
        }
    }
    
    class func didRegisterForRemoutNotification(_ deviceToken: Data) {
        let characterSet: CharacterSet = CharacterSet( charactersIn: "<>" )
        
        let deviceTokenString: String? = ( deviceToken.description as NSString )
            .trimmingCharacters( in: characterSet )
            .replacingOccurrences(of: " ", with: "" ) as String
    }
    
    class func didReceiveRemoutNotification(_ userInfo: [AnyHashable: Any], identifier: String? = nil , responseInfo: [AnyHashable: Any]? = nil) {
        
        guard let aps = userInfo["aps"] as? NSDictionary else {return}
        guard let badge = aps.value(forKey: "badge") as? Int else {return}
        
        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber - badge
    }
    
    fileprivate class func showNotificationBaner(_ title: String){
        var root = UIApplication.shared.windows.first?.rootViewController
        
        for ;; {
            if root?.presentedViewController != nil {
                root = root?.presentedViewController
            } else {
                break
            }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let identifire = "NotificationBaner"
        let controller :NotificationBaner =  storyboard.instantiateViewController(withIdentifier: identifire) as! NotificationBaner
        
        if let root = root {
            controller.view.frame.origin.y = -70
            controller.view.frame.size.height = 70
            root.view.addSubview(controller.view)
            controller.titleLabel.text = title
            controller.showBaner()
        }
    }
    
    //MARK: Local notification
    
    class func didReceiveLocalNotificaton(_ notification: UILocalNotification) {
        print(notification)
        showNotificationBaner(notification.alertBody!)
        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber - 1

    }
    
    class func sheduleLocalNotificationAfter(_ titile: String, body: String, interval: Double, userInfo: [AnyHashable: Any]?) {
        let localNotification = UILocalNotification()
        localNotification.fireDate = Date(timeIntervalSinceNow: interval)
        localNotification.timeZone = TimeZone.current
        localNotification.alertTitle = titile
        localNotification.alertBody = body
        localNotification.userInfo = userInfo
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
}
