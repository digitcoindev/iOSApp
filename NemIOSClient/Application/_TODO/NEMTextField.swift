import UIKit

protocol NEMTextFieldDelegate {
    func newNemTexfieldSize(_ size: CGSize)
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
    
    fileprivate var _suggestions :[Suggestion] = []
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
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
        tableView.frame = CGRect(x: 0, y: self.frame.height, width: self.frame.width, height: 0)
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        self.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "standart")
        
        self.addTarget(self, action: #selector(NEMTextField.updateSuggestions(_:)), for: UIControlEvents.editingChanged)
        self.addTarget(self, action: #selector(NEMTextField.hideSuggenstions(_:)), for: UIControlEvents.editingDidEnd)

    }
    
    func updateSuggestions(_ sender: AnyObject) {
        
        _suggestions = []
        
        for suggestion in suggestions {
            if NSPredicate(format: "SELF BEGINSWITH[c] %@",self.text!).evaluate(with: suggestion.key) && self.text! != suggestion.key
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
            tableView.isHidden = false
            tableView.reloadData()
        } else {
            self.nemDelegate?.newNemTexfieldSize(CGSize(width: self.frame.width, height: self.frame.height))

            tableView.isHidden = true
        }
    }
    
    func hideSuggenstions(_ sender: AnyObject) {
        tableView.isHidden = true
        
        self.nemDelegate?.newNemTexfieldSize(CGSize(width: self.frame.width, height: self.frame.height))
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width - 15, height: bounds.height)
        return rect.insetBy(dx: 10, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    // MARK: - TableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _suggestions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "standart")!
        
        var resultSuggestion = _suggestions[(indexPath as NSIndexPath).row].value
        if _suggestions[(indexPath as NSIndexPath).row].value != _suggestions[(indexPath as NSIndexPath).row].key {
            resultSuggestion = _suggestions[(indexPath as NSIndexPath).row].key + " " + "(\(_suggestions[(indexPath as NSIndexPath).row].value))"
        }
        
        cell.textLabel?.text = resultSuggestion
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.text = _suggestions[(indexPath as NSIndexPath).row].value
        updateSuggestions(self)
    }
}
