import UIKit
typealias funcBlock = () -> ()

class ButtonDropDown: UIButton  , UITableViewDelegate , UITableViewDataSource
{
    var tableView :UITableView!
    var dinamicDropDown :Bool = true
    var dropMenuHeight :CGFloat = 132
    var content: [String] = [String]()
    var contentAtions: [funcBlock] = [funcBlock]()
    var selectedRow :Int!

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.setup()
    }
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.setup()
    }

    func setup()
    {
        tableView = UITableView(frame: CGRectMake(0,self.frame.height, self.frame.width, dropMenuHeight))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.hidden = true
        
        self.addSubview(tableView)
        self.addTarget(self, action: "touchUpInside", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView?
    {
        var frame :CGRect = CGRectMake(0,self.bounds.height, self.bounds.width, tableView.bounds.height)
        if CGRectContainsPoint(frame, point) && !tableView.hidden
        {
            return tableView
        }
        
        if CGRectContainsPoint(self.bounds, point)
        {
            return self
        }
        
        return nil
    }
    
    final func setDropDownMenuHeight(height: CGFloat)
    {
        dropMenuHeight = height
        dinamicDropDown = false
        
        tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, self.frame.size.width, dropMenuHeight);
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return content.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell = UITableViewCell()
        cell.textLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle
        cell.textLabel!.text = content[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        selectedRow = indexPath.row
        
        self.setTitle(content[selectedRow], forState: UIControlState.Normal)
        self.setTitle(content[selectedRow], forState: UIControlState.Selected)
        self.setTitle(content[selectedRow], forState: UIControlState.Disabled)
        
        tableView.hidden = true
        
        if contentAtions.count == content.count
        {
            contentAtions[selectedRow]()
        }
    }
    
    final func setContent(content :[String] , contentActions :[funcBlock]?)
    {
        self.content = content
        
        if contentActions != nil
        {
            self.contentAtions = contentActions!
        }
    }
    
    final func touchUpInside()
    {
        tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, self.frame.size.width, dropMenuHeight);

        if content.count == 0
        {
            tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 0)
        }
        else if dinamicDropDown
        {
            tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, CGFloat(content.count * 44) )
        }
        else
        {
            tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, dropMenuHeight)
        }
        
        tableView.reloadData()
        
        tableView.hidden = !tableView.hidden

    }
}
