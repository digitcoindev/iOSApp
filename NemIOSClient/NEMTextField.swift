import UIKit

protocol NEMTextFieldDelegate {
    func newNemTexfieldSize(size: CGSize)
}

class NEMTextField: UITextField, UITableViewDelegate, UITableViewDataSource
{
    struct Suggestion {
        var key :String = ""
        var value :String = ""
    }
    
    var suggestions :[Suggestion] = []
    var nemDelegate :NEMTextFieldDelegate? = nil
    let tableView :UITableView = UITableView()
    var tableViewMaxRows :Int = 5
    
    private var _suggestions :[Suggestion] = []
    
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
        
        self.addTarget(self, action: #selector(NEMTextField.updateSuggestions(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.addTarget(self, action: #selector(NEMTextField.hideSuggenstions(_:)), forControlEvents: UIControlEvents.EditingDidEnd)

    }
    
    func updateSuggestions(sender: AnyObject) {
        
        _suggestions = []
        
        for suggestion in suggestions {
            if NSPredicate(format: "SELF BEGINSWITH[c] %@",self.text!).evaluateWithObject(suggestion.key) && self.text! != suggestion.key
            {
                _suggestions.append(suggestion)
            }
        }
        
        if suggestions.count > 0 {
            tableView.frame.size.height = CGFloat(40 * ((_suggestions.count > tableViewMaxRows) ? tableViewMaxRows : _suggestions.count))
    
            let newSize = CGSize(
                width: max(self.frame.width, self.tableView.frame.width),
                height: tableView.frame.origin.y + tableView.frame.height
            )
            
            self.nemDelegate?.newNemTexfieldSize(newSize)
            
            tableView.frame.size.width = self.frame.width
            tableView.hidden = false
            tableView.reloadData()
        } else {
            self.nemDelegate?.newNemTexfieldSize(CGSize(width: self.frame.width, height: self.frame.height))

            tableView.hidden = true
        }
    }
    
    func hideSuggenstions(sender: AnyObject) {
        tableView.hidden = true
        
        self.nemDelegate?.newNemTexfieldSize(CGSize(width: self.frame.width, height: self.frame.height))
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
        
        var resultSuggestion = _suggestions[indexPath.row].value
        if _suggestions[indexPath.row].value != _suggestions[indexPath.row].key {
            resultSuggestion = _suggestions[indexPath.row].key + " " + "(\(_suggestions[indexPath.row].value))"
        }
        
        cell.textLabel?.text = resultSuggestion
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.text = _suggestions[indexPath.row].value
        updateSuggestions(self)
    }
}
