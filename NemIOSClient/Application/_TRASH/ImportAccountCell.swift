import UIKit

class ImportAccountCell: UITableViewCell
{
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var password: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }


    
    @IBAction func sandNotification(_ sender: UITextField) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Import"), object:sender.text )
        
        password.text = ""
    }
    
    
}
