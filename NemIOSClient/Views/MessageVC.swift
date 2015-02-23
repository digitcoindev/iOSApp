import UIKit

class MessageVC: UIViewController , UITableViewDelegate , UIAlertViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var NEMinput: UITextField!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    let dataManager :CoreDataManager = CoreDataManager()
    let contact :Correspondent = State.currentContact!
    var messages  :[Message]!
    var showKeyboard :Bool = false
    var nems :Int = 0
    var rowLength :Int = 21
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if State.fromVC != SegueToMessageVC
        {
            State.fromVC = SegueToMessageVC
        }
        
        State.currentVC = SegueToMessageVC

        messages = contact.messages.allObjects as [Message]
        sortMessages()
        
        userName.text = contact.name

        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: "scrollToEnd:", name: "scrollToEnd", object: nil)
        
        NSNotificationCenter.defaultCenter().postNotificationName("Title", object:State.currentContact!.name )
        
        inputText.layer.cornerRadius = 2
        NEMinput.layer.cornerRadius = 2
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        NSNotificationCenter.defaultCenter().postNotificationName("scrollToEnd", object:nil )

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(animated: Bool)
    {
        userName.frame = CGRectMake(userName.frame.origin.x - 48, userName.frame.origin.y, userName.frame.size.width, userName.frame.size.height)
    }
    
    @IBAction func closeKeyboard(sender: UITextField)
    {
        sender.becomeFirstResponder()
    }
    
    @IBAction func doNotScroll(sender: UITextField)
    {

        showKeyboard = true

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(messages.count < 12)
        {
            return 12
        }
        else
        {
            return messages.count
        }
    }
    
    @IBAction func send(sender: AnyObject)
    {
        var text :String = inputText.text
        
        if text != "" || nems > 0
        {
            if messages.count % 2 == 0
            {
                dataManager.addMessage("me", to: contact.key, message: text, date: NSDate() ,nems :"\(nems)")
            }
            else
            {
                dataManager.addMessage(contact.key, to: "me", message: text, date: NSDate() ,nems :"\(nems)")
            }

            nems = 0;
            balance.text = ""
            inputText.text = ""
            
            messages = contact.messages.allObjects as [Message]
            sortMessages()
            
            tableView.reloadData()
            
            NSNotificationCenter.defaultCenter().postNotificationName("scrollToEnd", object:nil )
        }
    }
    
    func setString(message :String)->CGFloat
    {
        var numberOfRows :Int = 0
        for component :String in message.componentsSeparatedByString("\n")
        {
            numberOfRows += 1
            numberOfRows += countElements(component) / rowLength
        }
        
        var height : Int = numberOfRows  * 17
        
        return CGFloat(height)
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat
    {
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if(12 - indexPath.row  <= messages.count)
        {
            var index :Int!
            
            if(messages.count < 12)
            {
                index = indexPath.row  -  12 + messages.count
            }
            else
            {
                index = indexPath.row 
            }
            
            var cell : CustomMessageCell!
            
            if (messages[index].from != "me")
            {
                cell = self.tableView.dequeueReusableCellWithIdentifier("inCell") as CustomMessageCell
            }
            else
            {
                cell = self.tableView.dequeueReusableCellWithIdentifier("outCell") as CustomMessageCell
            }
            
            var message :NSMutableAttributedString = NSMutableAttributedString(string: messages[index].message , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 12.0)!])
            
            if(messages[index].nems.toInt() != 0)
            {
                var text :String = "\(messages[index].nems) XEMs"
                if messages[index].message != ""
                {
                    text = "\n" + text
                }
                
                var messageXEMS :NSMutableAttributedString = NSMutableAttributedString(string:text , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 17.0)! ])
                message.appendAttributedString(messageXEMS)
            }
            
            var messageDate :NSMutableAttributedString = NSMutableAttributedString(string:"\n" , attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 12.0)! ])
            message.appendAttributedString(messageDate)
            
            cell.message.attributedText = message
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm dd.MM.yy "
            
            cell.date.text = dateFormatter.stringFromDate(messages[index].date)
            
            if(indexPath.row == tableView.numberOfRowsInSection(0) - 1)
            {
                NSNotificationCenter.defaultCenter().postNotificationName("scrollToEnd", object:nil )
            }
            
            cell.message.layer.cornerRadius = 5
            cell.message.layer.masksToBounds = true
            
            return cell
        }
        else
        {
            var cell    :UITableViewCell  = self.tableView.dequeueReusableCellWithIdentifier("simpl") as UITableViewCell
            return cell as UITableViewCell
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if(12 - indexPath.row  <= messages.count)
        {
            var index :Int!
            if(messages.count < 12)
            {
                index = indexPath.row  -  12 + messages.count
            }
            else
            {
                index = indexPath.row
            }
            
            var height :CGFloat = heightForView(messages[index].message, font: UIFont(name: "HelveticaNeue", size: 12.0)!, width: tableView.frame.width - 66)
        
            if  messages[index].nems.toInt() != 0
            {
                height += heightForView("\n" + messages[index].nems, font: UIFont(name: "HelveticaNeue", size: 17.0)!, width: tableView.frame.width - 66)
            }
            else
            {
                height += 20
            }
            
            return  height
        }
        else
        {
            return 44
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {

    }
    
    @IBAction func addNems(sender: AnyObject)
    {
        if (sender as UITextField).text.toInt() != nil
        {
            self.nems = (sender as UITextField).text.toInt()!
        }
        
        if self.nems > 0
        {
            balance.text = "Fee: \(self.nems) XEMs"
            (sender as UITextField).text = ""
        }
        else
        {
            self.nems = 0
            (sender as UITextField).text = ""
            balance.text = ""
        }
        
    }


    
    func sortMessages()
    {
        var accum :Message!
        for(var index = 0; index < messages.count; index++)
        {
            for(var index = 0; index < messages.count - 1; index++)
            {
                if messages[index].date.compare(messages[index + 1].date) == NSComparisonResult.OrderedDescending
                {
                    accum = messages[index]
                    messages[index] = messages[index + 1]
                    messages[index + 1] = accum
                }
            }
        }
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
        if(showKeyboard)
        {
            var info:NSDictionary = notification.userInfo!
            var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
            
            var keyboardHeight:CGFloat = keyboardSize.height
            
            var animationDuration = 0.25
            
            UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                    {
                        self.view.frame = CGRectMake(0, -keyboardHeight, self.view.bounds.width, self.view.bounds.height)
                    }, completion: nil)
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        if(showKeyboard)
        {
            var info:NSDictionary = notification.userInfo!
            var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as NSValue).CGRectValue()
        
            var keyboardHeight:CGFloat = keyboardSize.height
            

        
            var animationDuration:CGFloat = info[UIKeyboardAnimationDurationUserInfoKey] as CGFloat
        
            UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations:
                {
                    self.view.frame = CGRectMake(0, (self.view.frame.origin.y + keyboardHeight), self.view.bounds.width, self.view.bounds.height)
            
                }, completion: nil)
        }
    }

    override func viewWillDisappear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
}
