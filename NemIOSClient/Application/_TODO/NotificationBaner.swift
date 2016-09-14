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
    
    fileprivate var timer :Timer? = nil
    fileprivate let banerHeightFull :CGFloat = 70
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    @IBAction func closeBaner() {
        timer?.invalidate()
        timer = nil
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.frame.origin.y = -self.banerHeightFull
            }, completion: { (success) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        }) 
    }
    
    func showBaner() {
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(NotificationBaner.closeBaner), userInfo: nil, repeats: false)
        
        self.view.frame.origin.y = -banerHeightFull
        self.view.frame.size.height = banerHeightFull

        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.frame.origin.y = 0
            })
    }
}
