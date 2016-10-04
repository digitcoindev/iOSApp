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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    func setup() {
        tableView = UITableView(frame: CGRect(x: 0,y: self.frame.height, width: self.frame.width, height: dropMenuHeight))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        
        self.addSubview(tableView)
        self.addTarget(self, action: #selector(ButtonDropDown.touchUpInside), for: UIControlEvents.touchUpInside)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let frame :CGRect = CGRect(x: 0,y: self.bounds.height, width: self.bounds.width, height: tableView.bounds.height)
        if frame.contains(point) && !tableView.isHidden {
            return tableView
        }
        
        if self.bounds.contains(point) {
            return self
        }
        
        return nil
    }
    
    final func setDropDownMenuHeight(_ height: CGFloat) {
        dropMenuHeight = height
        dinamicDropDown = false
        
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: self.frame.size.width, height: dropMenuHeight);
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = UITableViewCell()
        cell.textLabel!.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
        cell.textLabel!.text = content[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        
        self.setTitle(content[selectedRow], for: UIControlState())
        self.setTitle(content[selectedRow], for: UIControlState.selected)
        self.setTitle(content[selectedRow], for: UIControlState.disabled)
        
        tableView.isHidden = true
        
        if contentAtions.count == content.count {
            contentAtions[selectedRow]()
        }
    }
    
    final func setContent(_ content :[String] , contentActions :[funcBlock]?) {
        self.content = content
        
        if contentActions != nil {
            self.contentAtions = contentActions!
        }
    }
    
    final func touchUpInside() {
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: self.frame.size.width, height: dropMenuHeight);

        if content.count < 1 {
            tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: 0)
        }
        else if dinamicDropDown {
            tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: CGFloat(content.count * 44) )
        }
        else {
            tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: dropMenuHeight)
        }
        
        tableView.reloadData()
        
        tableView.isHidden = !tableView.isHidden

    }
}
