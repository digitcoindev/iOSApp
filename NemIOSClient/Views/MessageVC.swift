//
//  MessageVC.swift
//  NemIOSClient
//
//  Created by Bodya Bilas on 30.12.14.
//  Copyright (c) 2014 Artygeek. All rights reserved.
//

import UIKit
import AddressBook

class MessageVC: UIViewController , UITableViewDelegate , UIAlertViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputText: UITextField!
    
    var testMessage  : NSMutableArray = ["Hi","HI","How are you?","I'm fine!"]
    var canScroll :Bool = false
    var nems :Int = 0
    let addressBook : ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: "scrollToEnd:", name: "scrollToEnd", object: nil)
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        
        
//        ABAddressBookRequestAccessWithCompletion(addressBook,
//            {
//                (granted : Bool, error: CFError!) -> Void in
//                if granted == true
//                {
//                    let allContacts : NSArray = ABAddressBookCopyArrayOfAllPeople(self.addressBook).takeRetainedValue()
//                    for contactRef:ABRecordRef in allContacts
//                    {
//                        // first name
//                        if let firstName = ABRecordCopyValue(contactRef, kABPersonFirstNameProperty).takeUnretainedValue() as? NSString
//                        {
//                            println(firstName)
//                        }
//                    }
//                }
//                else
//                {
//                    println("no access")
//
//                }
//        })
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(testMessage.count < 12)
        {
            return 12
        }
        else
        {
            return testMessage.count
        }
    }
    
    @IBAction func send(sender: AnyObject)
    {
        var text :String = inputText.text
        
        if(nems != 0)
        {
            text += " (\(nems) NEMs)"
        }
        
        testMessage.addObject(text)
        nems = 0;
        inputText.text = ""
        
        tableView.reloadData()
        
        NSNotificationCenter.defaultCenter().postNotificationName("scrollToEnd", object:nil )
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if(12 - indexPath.row  <= testMessage.count)
        {
            var index :Int!
            if(testMessage.count < 12)
            {
                index = indexPath.row  -  12 + testMessage.count
            }
            else
            {
                index = indexPath.row 
            }
            if (indexPath.row % 2 == 0)
            {
                var inCell : InMessageCell = self.tableView.dequeueReusableCellWithIdentifier("inCell") as InMessageCell
                
                
                inCell.message.text = testMessage[index] as? String
                
                if(indexPath.row == tableView.numberOfRowsInSection(0) - 1)
                {
                    println("+")
                    NSNotificationCenter.defaultCenter().postNotificationName("scrollToEnd", object:nil )
                }
                
                return inCell
            }
            else
            {
                var outCell : OutMessageCell = self.tableView.dequeueReusableCellWithIdentifier("outCell") as OutMessageCell
                
                outCell.message.text = testMessage[index] as? String
                
                if(indexPath.row == tableView.numberOfRowsInSection(0) - 1)
                {
                    println("+")
                    NSNotificationCenter.defaultCenter().postNotificationName("scrollToEnd", object:nil )
                }
                
                return outCell
            }
        }
        else
        {
            return UITableViewCell()
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {

    }
    
    @IBAction func addNems(sender: AnyObject)
    {
        var alert :UIAlertView = UIAlertView(title: "Add NEMs", message: "Are you sure ?", delegate: self, cancelButtonTitle: "CANCEL", otherButtonTitles: "I'm sure!")
        var alert1 :UIAlertController = UIAlertController(title: "Add NEMs", message: "Are you sure ?", preferredStyle: UIAlertControllerStyle.Alert)
        
        var newTextField :UITextField!
        alert1.addTextFieldWithConfigurationHandler
            {
                textField -> Void in
                textField.placeholder = "input NEMs count"
                textField.keyboardType = UIKeyboardType.ASCIICapable
                textField.returnKeyType = UIReturnKeyType.Done
                
                newTextField = textField
            
        }
        
        var addNems :UIAlertAction = UIAlertAction(title: "Add NEMs", style: UIAlertActionStyle.Default)
            {
                alertAction -> Void in
                self.nems += newTextField.text.toInt()!
        }
        
        var cancel :UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
            {
                alertAction -> Void in
                alert1.dismissViewControllerAnimated(true, completion: nil)
        }

        alert1.addAction(addNems)
        alert1.addAction(cancel)
        
        self.presentViewController(alert1, animated: true, completion: nil)
    }

    
    func scrollToEnd(notification: NSNotification)
    {
        var pos :Int!
        if(tableView.numberOfRowsInSection(0) < 12)
        {
            pos = 0
        }
        else
        {
            pos = tableView.numberOfRowsInSection(0) - 1
        }
        var indexPath1 :NSIndexPath = NSIndexPath(forRow: pos , inSection: 0)
        
        tableView.scrollToRowAtIndexPath(indexPath1, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        var info:NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        var animationDuration:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as CGFloat
        
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.frame = CGRectMake(0, (self.view.frame.origin.y - keyboardHeight), self.view.bounds.width, self.view.bounds.height)
            }, completion: nil)
        
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        if(canScroll)
        {
        var info:NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
        
        var keyboardHeight:CGFloat = keyboardSize.height
        
        var animationDuration:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as CGFloat
        
        UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.frame = CGRectMake(0, (self.view.frame.origin.y + keyboardHeight), self.view.bounds.width, self.view.bounds.height)
            
            }, completion: nil)
        }
        
        canScroll = true
        
    }

    override func viewWillDisappear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
}
