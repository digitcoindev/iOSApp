import UIKit

let SegueToServerVC : String =  "Servers"
let SegueToRegistrationVC : String =  "Registration"
let SegueToLoginVC : String =  "Accounts"
let SegueToServerTable : String =  "serverTable"
let SegueToServerCustom : String =  "serverCustom"
let SegueToMainVC : String =  "Main"
let SegueToMainMenu : String =  "Menu"
let SegueToDashboard : String =  "Dashboard"
let SegueToPasswordValidation : String =  "Password"
let SegueToMessageVC : String =  "Message"
let SegueToQRCode : String =  "QR Code"
let SegueToAddAccountVC :String = "Import Accouts"
let SegueToImportFromQR :String = "Import from QR"
let SegueToAddressBook :String = "Address Book"
let SegueToMessages :String = "Messages"
let SegueToUserInfo :String = "User Info"
let SegueToImportFromKey :String = "Import from key"
let SegueToCreateQRInput :String = "CreateQRInput"
let SegueToCreateQRResult :String = "CreateQRResult"
let SegueToGoogleMap :String = "Map"
let SegueToAddFriend :String = "Add Friend"

let genesis_block_time :Double = 1422741600


class ViewController: UIViewController
{
    let deviceData : plistFileManager = plistFileManager()
    let dataManager :CoreDataManager = CoreDataManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool)
    {
       self.performSegueWithIdentifier(SegueToMainVC, sender: self)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

}

