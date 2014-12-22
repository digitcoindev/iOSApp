//
//  ServerContainerVC.swift
//  NemIOSClient
//
//  Created by Dominik Lyubomyr on 12.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit


class ServerContainerVC: UIViewController {


    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.performSegueWithIdentifier(SegueToServerTable, sender: self);
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
        toViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)
        fromViewController.willMoveToParentViewController(nil)
        self.addChildViewController(toViewController)
        self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromRight, animations:
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

    internal func changePage(page :Int)
    {
        switch(page)
        {
            
        case 0:
            self.performSegueWithIdentifier(SegueToServerTable, sender: nil)
            break;
            
        case 1:
            self.performSegueWithIdentifier(SegueToServerCustom, sender: nil)
            break;
            
        default:
            break;
        }
    }
}
