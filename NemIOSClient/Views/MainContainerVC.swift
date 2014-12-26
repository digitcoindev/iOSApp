//
//  MainContainerVC.swift
//  NemIOSClient
//
//  Created by Bodya Bilas on 19.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit

class MainContainerVC: UIViewController
{
    let dataManager :CoreDataManager = CoreDataManager()
    
    var previousChange :Int  = -2
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        var wallets :[Wallet] = dataManager.getWallets()
        println("walets \(wallets.count) " )
        
        if(wallets.count == 0)
        {
            self.performSegueWithIdentifier(SegueToRegistrationVC, sender: self);
        }
        else if(State.currentWallet == -1)
        {
            self.performSegueWithIdentifier(SegueToLoginVC, sender: self);
        }
        else
        {
            self.performSegueWithIdentifier(SegueToMainMenu, sender: self);
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        
        if (self.childViewControllers.count > 0)
        {
            self.swapFromViewController(self.childViewControllers.first as UIViewController, toViewController: segue.destinationViewController as UIViewController)
        }
        else
        {
            self.addChildViewController(segue.destinationViewController as UIViewController)
            (segue.destinationViewController as UIViewController).view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
            
            self.view .addSubview((segue.destinationViewController as UIViewController).view)
            segue.destinationViewController.didMoveToParentViewController(self)
        }
        
    }
    
    func swapFromViewController(fromViewController :UIViewController , toViewController :UIViewController )
    {
        toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        fromViewController.willMoveToParentViewController(nil)
        
        self.addChildViewController(toViewController)
        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromRight
            , animations:
            {
                value in
            }
            , completion:
            {
                finish in
                
                fromViewController.removeFromParentViewController()
                toViewController.didMoveToParentViewController(self)
        })
    }
    func selectedPage(notification: NSNotification)
    {
        println("echo")
    }
    
    func changePage(page :Int)
    {
        if(page != previousChange)
        {
            previousChange = page
            switch(page)
                {
                
            case -1:
                self.performSegueWithIdentifier(SegueToMainMenu, sender: nil)
                
            case 0:
                self.performSegueWithIdentifier(SegueToRegistrationVC, sender: nil)
                
            case 1:
                self.performSegueWithIdentifier(SegueToLoginVC, sender: nil)
                
            case 2:
                self.performSegueWithIdentifier(SegueToServerVC, sender: nil)
                
            case 14:
                self.performSegueWithIdentifier(SegueToPinConfige, sender: nil)

            default:
                break
            }
        }
    }
}
