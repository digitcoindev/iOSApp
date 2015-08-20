import UIKit

class AddressCell: UITableViewCell
{

    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var indicator: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        indicator.enabled = false
        indicator.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
