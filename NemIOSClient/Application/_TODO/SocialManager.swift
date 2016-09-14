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
    
    func facebookPostToWall(_ message: String?, images: [UIImage]?, urls: [URL]?)
    func twitterPostToWall(_ message: String?, images: [UIImage]?, urls: [URL]?)
    func mailSand(_ message: String?, images: [Data]?)
}

class SocialManager: NSObject, MFMailComposeViewControllerDelegate, SocialManagerProtocol {
    
    var delegate :UIViewController? = nil
    
    // MARK: - Facebook Methods

    func facebookPostToWall(_ message: String?, images: [UIImage]?, urls: [URL]?) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
            
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            facebookSheet.setInitialText(message ?? "SOCIAL_NEM_HEADER".localized()) 
            
            self.delegate?.present(facebookSheet, animated: true, completion: nil)
            
        }
        else {
            let alert = UIAlertController(title: "INFO".localized(), message: "NO_FACEBOOK_ACCOUNT".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
            
            self.delegate?.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Twitter Methods

    func twitterPostToWall(_ message: String?, images: [UIImage]?, urls: [URL]?) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            facebookSheet.setInitialText(message ?? "SOCIAL_NEM_HEADER".localized())
            
            for image in images ?? [] {
                facebookSheet.add(image)
            }
            
            for url in urls ?? [] {
                facebookSheet.add(url)
            }
                        
            self.delegate?.present(facebookSheet, animated: true, completion: nil)
            
        }
        else {
            let alert = UIAlertController(title: "INFO".localized(), message: "NO_TWITTER_ACCOUNT".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
            
            self.delegate?.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Email Methods
    
    func mailSand(_ message: String?, images: [Data]?) {
        
        if(MFMailComposeViewController.canSendMail()) {
            let myMail : MFMailComposeViewController = MFMailComposeViewController()
            
            myMail.mailComposeDelegate = self
            
            myMail.setSubject("SOCIAL_NEM_HEADER".localized())
            myMail.setMessageBody(message ?? "", isHTML: true)
            
            for image in images ?? [] {
                myMail.addAttachmentData(image, mimeType: "image/jped", fileName: "image")
            }
            
            self.delegate?.present(myMail, animated: true, completion: nil)
        }
        else {            
            let alert = UIAlertController(title: "INFO".localized(), message: "NO_MAIL_ACCOUNT".localized(), preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.default, handler: nil))
            
            self.delegate?.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: -  MFMailComposeViewControllerDelegate Methos
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
