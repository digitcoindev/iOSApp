import UIKit

class CustomMessageCell: UITableViewCell
{
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var signees: UILabel!
    @IBOutlet weak var minCosig: UILabel!
    @IBOutlet weak var fee: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
