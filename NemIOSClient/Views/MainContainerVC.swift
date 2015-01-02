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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        var wallets :[Wallet] = dataManager.getWallets()
        println("walets \(wallets.count) " )
        
        if(wallets.count == 0)
        {
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToRegistrationVC )
            self.performSegueWithIdentifier(SegueToRegistrationVC, sender: self);
        }
        else if(State.currentWallet == -1)
        {
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToLoginVC )
            self.performSegueWithIdentifier(SegueToLoginVC, sender: self);
        }
        else
        {
            NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object:SegueToMainMenu )
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
    
    func changePage(page :String)
    {
        if(page != State.fromVC )
        {
            switch(page)
                {
                
            case SegueToMainMenu:
                self.performSegueWithIdentifier(SegueToMainMenu, sender: nil)
                
            case SegueToRegistrationVC:
                self.performSegueWithIdentifier(SegueToRegistrationVC, sender: nil)
                
            case SegueToLoginVC:
                self.performSegueWithIdentifier(SegueToLoginVC, sender: nil)
                
            case SegueToServerVC:
                self.performSegueWithIdentifier(SegueToServerVC, sender: nil)
                
            case SegueToDashboard:
                self.performSegueWithIdentifier(SegueToDashboard, sender: nil)
                
            case SegueToPasswordValidation:
                self.performSegueWithIdentifier(SegueToPasswordValidation, sender: nil)

            case SegueToQRCode:
                self.performSegueWithIdentifier(SegueToQRCode, sender: nil)

            case SegueToMessageVC:
                self.performSegueWithIdentifier(SegueToMessageVC, sender: nil)

            default:
                break
            }
            
            State.fromVC = page

        }
    }
}
