//
//  NotificationBaner.swift
//  jigit
//
//  Created by Lyubomir Dominik on 08.12.15.
//  Copyright © 2015 dominik. All rights reserved.
//

import UIKit

class NotificationBaner: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    private var timer :NSTimer? = nil
    private let banerHeightFull :CGFloat = 70
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = true
    }
    
    override func viewDidAppear(animated: Bool) {

    }
    
    @IBAction func closeBaner() {
        timer?.invalidate()
        timer = nil
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.frame.origin.y = -self.banerHeightFull
            }) { (success) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        }
    }
    
    func showBaner() {
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("closeBaner"), userInfo: nil, repeats: false)
        
        self.view.frame.origin.y = -banerHeightFull
        self.view.frame.size.height = banerHeightFull

        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.frame.origin.y = 0
            })
    }
}
