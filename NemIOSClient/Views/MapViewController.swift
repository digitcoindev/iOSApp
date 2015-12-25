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
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        titleLabel.text = "MAP".localized()
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
