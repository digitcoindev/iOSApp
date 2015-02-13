import UIKit

class ServerViewCell: UITableViewCell
{
    @IBOutlet weak var serverName: UILabel!
    @IBOutlet weak var indicator: UIButton!

    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    func indicatorON()
    {
        indicator.highlighted = true
    }
    
    func disSelect()
    {
        indicator.highlighted = false

    }
}
