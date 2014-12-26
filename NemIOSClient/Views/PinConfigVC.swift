//
//  PinConfigVC.swift
//  NemIOSClient
//
//  Created by Bodya Bilas on 26.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit

class PinConfigVC: UIViewController
{
    @IBOutlet weak var confirmB: UIButton!
    
    @IBOutlet weak var oldPin: UITextField!
    @IBOutlet weak var newPin: UITextField!
    @IBOutlet weak var repeatPin: UITextField!
    
    @IBOutlet weak var pinOnOff: UISwitch!
    
    @IBOutlet weak var lableOldPin: UILabel!
    @IBOutlet weak var lableNewPin: UILabel!
    @IBOutlet weak var lableRepeatPin: UILabel!
    
    let dataManager :CoreDataManager = CoreDataManager()
    
    var user :User!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        user = dataManager.getUsers()[0]
        if(user.state == "0" )
        {
            pinOnOff.setOn(false, animated: true)
            
            lableOldPin.hidden = true
            lableNewPin.hidden = true
            lableRepeatPin.hidden = true
            
            oldPin.hidden = true
            newPin.hidden = true
            repeatPin.hidden = true
            
            confirmB.hidden = true
        }
        else
        {
            pinOnOff.setOn(true, animated: true)
            
        }
    }
    @IBAction func changePinState(sender: AnyObject)
    {
        if !pinOnOff.on
        {
            pinOnOff.setOn(false, animated: true)
            
            lableOldPin.hidden = true
            lableNewPin.hidden = true
            lableRepeatPin.hidden = true
            
            oldPin.hidden = true
            newPin.hidden = true
            repeatPin.hidden = true
            
            confirmB.hidden = true
        }
        else
        {
            pinOnOff.setOn(true, animated: true)
            
            lableOldPin.hidden = false
            lableNewPin.hidden = false
            lableRepeatPin.hidden = false
            
            oldPin.hidden = false
            newPin.hidden = false
            repeatPin.hidden = false
            
            confirmB.hidden = false
        }
    }

    @IBAction func confirmChange(sender: AnyObject)
    {
        var rightData :Bool = true
        if(oldPin.text != dataManager.userPin())
        {
            oldPin.text = ""
            oldPin.placeholder = "incorrect pin"
            rightData = false
        }
        if((newPin.text as NSString).length < 6)
        {
            newPin.text = ""
            newPin.placeholder = "too short pin"
            rightData = false
        }
        if(newPin.text != repeatPin.text)
        {
            repeatPin.text = ""
            repeatPin.placeholder = "not similar pin codes"
            rightData = false
        }
        if rightData
        {
            dataManager.userPin(newPin.text)
            
            oldPin.text = ""
            oldPin.placeholder = "Success"
            
            newPin.text = ""
            newPin.placeholder = "Success"
            
            repeatPin.text = ""
            repeatPin.placeholder = "Success"
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
