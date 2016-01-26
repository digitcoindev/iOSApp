import UIKit

class NEMTextField: UITextField, UITableViewDelegate, UITableViewDataSource
{
    var suggestions :[String] = []
    let tableView :UITableView = UITableView()
    
    private var _suggestions :[String] = []
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if tableView.frame.contains(point) {
            return tableView
        }
        
        if self.bounds.contains(point) {
            return self
        }
        
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = false
        tableView.frame = CGRectMake(0, self.frame.height, self.frame.width, 0)
        tableView.hidden = true
        tableView.delegate = self
        tableView.dataSource = self
        self.addSubview(tableView)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "standart")
        
        self.addTarget(self, action: "updateSuggestions:", forControlEvents: UIControlEvents.EditingChanged)
        self.addTarget(self, action: "hideSuggenstions:", forControlEvents: UIControlEvents.EditingDidEnd)

    }
    
    func updateSuggestions(sender: AnyObject) {
        
        _suggestions = []
        
        for suggestion in suggestions {
            if NSPredicate(format: "SELF BEGINSWITH[c] %@",self.text!).evaluateWithObject(suggestion) && self.text! != suggestion
            {
                _suggestions.append(suggestion)
            }
        }
        
        if suggestions.count > 0 {
            tableView.frame.size.height = CGFloat(40 * ((_suggestions.count > 5) ? 5 : _suggestions.count))
            tableView.frame.size.width = self.frame.width
            tableView.hidden = false
            tableView.reloadData()
        } else {
            tableView.hidden = true
        }
    }
    
    func hideSuggenstions(sender: AnyObject) {
        tableView.hidden = true
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        let rect = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.width - 15, bounds.height)
        return CGRectInset(rect, 10, 0)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
    
    // MARK: - TableViewDelegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _suggestions.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("standart")!
        cell.textLabel?.text = _suggestions[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.text = _suggestions[indexPath.row]
        updateSuggestions(self)
    }
}
