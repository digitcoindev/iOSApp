//
//  MapViewController.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 20.10.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class MapViewController: AbstractViewController {

    //MARK: - Load Methods
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IBActions
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToMainMenu)
        }
    }
}
