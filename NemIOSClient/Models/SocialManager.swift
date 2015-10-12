//
//  SocialManager.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 09.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit
import Social
import MessageUI

protocol SocialManagerProtocol {
    var delegate: UIViewController? { get set }
    
    func facebookPostToWall(message: String?, images: [UIImage]?, urls: [NSURL]?)
    func twitterPostToWall(message: String?, images: [UIImage]?, urls: [NSURL]?)
    func mailSand(message: String?, images: [NSData]?)
}

class SocialManager: NSObject, MFMailComposeViewControllerDelegate, SocialManagerProtocol {
    
    var delegate :UIViewController? = nil
    
    // MARK: - Facebook Methods

    func facebookPostToWall(message: String?, images: [UIImage]?, urls: [NSURL]?) {
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            facebookSheet.setInitialText(message ?? NSLocalizedString("SOCIAL_NEM_HEADER", comment: "Title"))
            
            for image in images ?? [] {
                facebookSheet.addImage(image)
            }
            
            for url in urls ?? [] {
                facebookSheet.addURL(url)
            }
            
            self.delegate?.presentViewController(facebookSheet, animated: true, completion: nil)
            
        }
        else {
            let alert = UIAlertController(title: NSLocalizedString("SOCIAL_NEM_HEADER", comment: "Title"), message: NSLocalizedString("NO_FACEBOOK_ACCOUNT", comment: "Description"), preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.delegate?.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Twitter Methods

    func twitterPostToWall(message: String?, images: [UIImage]?, urls: [NSURL]?) {
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            facebookSheet.setInitialText(message ?? NSLocalizedString("SOCIAL_NEM_HEADER", comment: "Title"))
            
            for image in images ?? [] {
                facebookSheet.addImage(image)
            }
            
            for url in urls ?? [] {
                facebookSheet.addURL(url)
            }
            
            self.delegate?.presentViewController(facebookSheet, animated: true, completion: nil)
            
        }
        else {
            let alert = UIAlertController(title: NSLocalizedString("SOCIAL_NEM_HEADER", comment: "Title"), message: NSLocalizedString("NO_TWITTER_ACCOUNT", comment: "Description"), preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.delegate?.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Email Methods
    
    func mailSand(message: String?, images: [NSData]?) {
        
        if(MFMailComposeViewController.canSendMail()) {
            let myMail : MFMailComposeViewController = MFMailComposeViewController()
            
            myMail.mailComposeDelegate = self
            
            myMail.setSubject(NSLocalizedString("SOCIAL_NEM_HEADER", comment: "Title"))
            myMail.setMessageBody(message ?? "", isHTML: true)
            
            for image in images ?? [] {
                myMail.addAttachmentData(image, mimeType: "image/jped", fileName: "image")
            }
            
            self.delegate?.presentViewController(myMail, animated: true, completion: nil)
        }
        else {
            let alert :UIAlertView = UIAlertView(title: NSLocalizedString("INFO", comment: "Title"), message: NSLocalizedString("NO_MAIL_ACCOUNT", comment: "Description"), delegate: self, cancelButtonTitle: "OK")
            alert.show()
        }
    }

    // MARK: -  MFMailComposeViewControllerDelegate Methos
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}