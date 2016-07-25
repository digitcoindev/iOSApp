import UIKit

class UnconfirmedTransactionCell: UITableViewCell
{
    @IBOutlet weak var fromAccount: UILabel!
    @IBOutlet weak var toAccount: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var xem: UILabel!
    @IBOutlet weak var confirm: UIButton!
    @IBOutlet weak var showChanges: UIButton?
    
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel?
    
    weak var delegate :TransactionUnconfirmedViewController? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        fromLabel.text = "FROM".localized() + ":"
        toLabel.text = "TO".localized() + ":"
        confirm.setTitle("CONFIRM".localized(), forState: UIControlState.Normal)
        showChanges?.setTitle("SHOW_CHANGES".localized(), forState: UIControlState.Normal)
        
        fromAccount.text = ""
        toAccount.text = ""
        if message != nil {
            messageLabel?.text = "MESSAGE".localized() + ":"
            message.text = ""
            xem.text = "0 XEM"
        }
        
        confirm.layer.cornerRadius = 5
        showChanges?.layer.cornerRadius = 5
        
        self.layer.cornerRadius = 10
    }

    @IBAction func confirmTouchUpInside(sender: AnyObject) {
        self.delegate?.confirmTransactionAtIndex(self.tag)
    }
    @IBAction func showTouchUpInside(sender: AnyObject) {
        self.delegate?.showTransactionAtIndex(self.tag)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
