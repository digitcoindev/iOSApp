import UIKit

class Messages: UIViewController , UITableViewDelegate ,UISearchBarDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var key: UILabel!

    let dataManager : CoreDataManager = CoreDataManager()
    var correspondents : NSArray = NSArray()
    var displayList :NSArray = NSArray()
    var searchBar : UISearchBar!
    var searchText :String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if State.fromVC != SegueToMessages
        {
            State.fromVC = SegueToMessages
        }

        State.currentVC = SegueToMessages

        correspondents = dataManager.getCorrespondents()
        displayList = correspondents
        
        var privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        var publicKey = KeyGenerator().generatePublicKey(privateKey)
        
        self.key.text = publicKey
        
        address.layer.cornerRadius = 2
        tableView.layer.cornerRadius = 2
        
        
        searchBar = UISearchBar(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.size.width, height: 44)))
        searchBar.delegate = self
        tableView.tableHeaderView = searchBar
        searchBar.showsCancelButton = true
        tableView.setContentOffset(CGPoint(x: 0, y: searchBar.frame.height), animated: false)

        if (State.currentContact != nil)
        {
            address.text = State.currentContact!.name
        }

    }
    
    override func viewDidAppear(animated: Bool)
    {
        tableView.setContentOffset(CGPoint(x: 0, y: 44), animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        tableView.setContentOffset(CGPoint(x: 0, y: 44), animated: true)
        
        displayList = correspondents
        
        tableView.reloadData()
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = true
    }
    
    func searchBarResultsListButtonClicked(searchBar: UISearchBar)
    {
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText == ""
        {
            displayList = correspondents
        }
        else
        {
            var predicate :NSPredicate = NSPredicate(format: "SELF.name contains[c] %@",searchText)!
            displayList = correspondents.filteredArrayUsingPredicate(predicate)
        }
        
        tableView.reloadData()

        
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return displayList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : MessageCell = self.tableView.dequeueReusableCellWithIdentifier("correspondent") as MessageCell
        var cellData  : Correspondent = displayList[indexPath.row] as Correspondent
        var messages :[Message] = cellData.messages.allObjects as [Message]
        
        cell.name.text = "  " + cellData.name
        
        if messages.count > 0
        {
            var messages :[Message] = cellData.messages.allObjects as [Message]
            
            var message :Message!
            
            if messages.count > 0
            {
                message = messages[0]
            }
            
            for mes :Message in messages
            {
                if mes.date.compare(message.date) == NSComparisonResult.OrderedDescending
                {
                    message = mes
                }
            }

            cell.message.text = "  " + message.message
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            cell.date.text = dateFormatter.stringFromDate(message.date)
        }
        else
        {
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        State.currentContact = correspondents[indexPath.row] as? Correspondent
        State.toVC = SegueToMessageVC
        
        NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToPasswordValidation )
    }
    
    @IBAction func inputAddress(sender: UITextField)
    {
        if sender.text != ""
        {
            var find :Bool = false
            
            for correspondetn in correspondents
            {
                if correspondetn.key == sender.text
                {
                    State.currentContact = correspondetn as? Correspondent
                    State.toVC = SegueToMessageVC
                    
                    find = true
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToPasswordValidation )
                }
            }
            
            if !find
            {
                State.currentContact = dataManager.addCorrespondent(sender.text, name: sender.text)
                State.toVC = SegueToMessageVC
                
                NSNotificationCenter.defaultCenter().postNotificationName("DashboardPage", object:SegueToPasswordValidation )
            }
        }
    }

    @IBAction func addressBook(sender: AnyObject)
    {
        State.toVC = SegueToMessages
        
        var alert :UIAlertView = UIAlertView(title: "Info", message: "Currently unavailable.\nIn developing process.", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    
    
    override func viewDidDisappear(animated: Bool)
    {
        
    }
}
