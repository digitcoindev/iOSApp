import UIKit

class KeyCell: UITableViewCell
{
    @IBOutlet weak var key: UILabel!
    @IBOutlet weak var indicator: UIButton!
    var cellIndex :Int = 0
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func touchUpInside(sender: AnyObject)
    {
        NSNotificationCenter.defaultCenter().postNotificationName("deleteCellAtIndex", object:cellIndex )
    }
}
