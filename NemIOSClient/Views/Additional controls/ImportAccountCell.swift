import UIKit

class ImportAccountCell: UITableViewCell
{
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var password: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }


    
    @IBAction func sandNotification(sender: UITextField) {
        NSNotificationCenter.defaultCenter().postNotificationName("Import", object:sender.text )
        
        password.text = ""
    }
    
    
}
