//
//  InvoceSettings.swift
//  NemIOSClient
//
//  Created by Lyubomir Dominik on 24.12.15.
//  Copyright © 2015 Artygeek. All rights reserved.
//

import UIKit

class InvoceSettings: AbstractViewController {
    
    //MARK: - @IBOutlet
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var prefixTextView: UITextView!
    @IBOutlet weak var postfixTextView: UITextView!
    @IBOutlet weak var prefixLabel: UILabel!
    @IBOutlet weak var postfixLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    private let _accounts :[Wallet] = CoreDataManager().getWallets()
    
    //MARK: - Load Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.cornerRadius = 5
        contentView.clipsToBounds = true
        let loadData = State.loadData
        
        prefixTextView.text = loadData?.invoicePrefix
        postfixTextView.text = loadData?.invoicePostfix
        
        prefixLabel.text = "PREFIX".localized()
        postfixLabel.text = "POSTFIX".localized()
        saveButton.setTitle("SAVE".localized(), forState: UIControlState.Normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - @IBAction
    
    @IBAction func closePopUp(sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    @IBAction func reset(sender: AnyObject) {
        let loadData = State.loadData
        loadData?.invoicePrefix = prefixTextView.text
        loadData?.invoicePostfix = postfixTextView.text
        CoreDataManager().commit()
        (self.delegate as! AbstractViewController).viewDidAppear(false)
        closePopUp(self)
    }
}
