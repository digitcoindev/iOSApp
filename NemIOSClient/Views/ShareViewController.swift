//
//  ShareViewController.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 09.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class ShareViewController: AbstractViewController {
    
    @IBOutlet weak var contentView: UIView!
    
    //MARK: - Private Variables

    var message :String? = nil
    var images :[UIImage]? = nil
    var urls :[NSURL]? = nil
    
    //MARK: - Private Variables
    
    private var _shareManager :SocialManagerProtocol = SocialManager()

    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func delegateIsSetted() {
        _shareManager.delegate = self.delegate as? UIViewController
    }
    
    //MARK: - @IBAction

    @IBAction func closePopUp(sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func shareWithMail(sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
        var data :[NSData] = []
        
        for image in images ?? [] {
            let imageData = UIImageJPEGRepresentation(image, 1.0)
            data.append(imageData!)
        }
        
        _shareManager.mailSand(message ?? "", images: data)
    }
    
    @IBAction func shareWithFacebook(sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
        _shareManager.facebookPostToWall(message, images: images, urls: urls)
    }
    
    @IBAction func shareWithTwitter(sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
        _shareManager.twitterPostToWall(message, images: images, urls: urls)
    }
}
