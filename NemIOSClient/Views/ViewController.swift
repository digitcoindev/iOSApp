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

let genesis_block_time :Double = 1427587212
let waitTime :Double = 5400

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
        AddressBookManager.create()
        
        self.performSegueWithIdentifier(SegueToMainVC, sender: self)
        
//        self.presentViewController(alert1, animated: true, completion: nil)
        
//        private key : 5ccf739d9f40f981e100492632cf729ae7940980e677551684f4f309bac5c59d
//        public key : cba08dd72505e0c6aa0b7521598c7c63ecef72bd48175355f9dd977664e4fcd1
//        address :TCUPVQC77TAMH7QKPFP5OT3TLUV4JYRPV6CEGJXW
//        server : 192.168.88.27
        
//        private key : 856f5bba369241ea2e171c32cb625aa975ec5c53ea0769f30a08f70f455a867e
//        public key : dd13a7d3eec54e859617093f8221ab22357c9925ecdacd3321c7bc07148f9f67
//        address :TCINVPKRY3X24RQMCWZLEEBJQU3GZFKCRW6NK46Y
//        server : 192.168.88.27
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

}

