//
//  ShareViewController.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 09.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    
    //MARK: - Private Variables

    var message :String? = nil
    var images :[UIImage]? = nil
    var urls :[URL]? = nil
    
    //MARK: - Private Variables
    
    fileprivate var _shareManager :SocialManagerProtocol = SocialManager()

    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
//    override func delegateIsSetted() {
//        _shareManager.delegate = self.delegate as? UIViewController
//    }
    
    //MARK: - @IBAction

    @IBAction func closePopUp(_ sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func shareWithMail(_ sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
        var data :[Data] = []
        
        for image in images ?? [] {
            let imageData = UIImageJPEGRepresentation(image, 1.0)
            data.append(imageData!)
        }
        
        _shareManager.mailSand(message ?? "", images: data)
    }
    
    @IBAction func shareWithFacebook(_ sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
        _shareManager.facebookPostToWall(message, images: images, urls: urls)
    }
    
    @IBAction func shareWithTwitter(_ sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
        _shareManager.twitterPostToWall(message, images: images, urls: urls)
    }
}
