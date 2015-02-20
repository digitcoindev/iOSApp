import UIKit

var SegueToServerVC : String =  "Servers"
var SegueToRegistrationVC : String =  "Registration"
var SegueToLoginVC : String =  "Accounts"
var SegueToServerTable : String =  "serverTable"
var SegueToServerCustom : String =  "serverCustom"
var SegueToMainVC : String =  "Main"
var SegueToMainMenu : String =  "Menu"
var SegueToDashboard : String =  "Dashboard"
var SegueToPasswordValidation : String =  "Password"
var SegueToMessageVC : String =  "Message"
var SegueToQRCode : String =  "QR Code"
var SegueToAddAccountVC :String = "Import Accouts"
var SegueToImportFromQR :String = "Import from QR"
var SegueToAddressBook :String = "Address Book"
var SegueToMessages :String = "Messages"
var SegueToUserInfo :String = "User Info"
var SegueToImportFromKey :String = "Import from key"
var SegueToCreateQRInput :String = "CreateQRInput"
var SegueToCreateQRResult :String = "CreateQRResult"
var SegueToGoogleMap :String = "Map"

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
        
        //Test data open
        
//        var importedAccounts :NSArray = NSArray(objects: "account 1","account 2" ,"account 3" ,"account 4")
//        
//        var manager :NSFileManager = NSFileManager()
//        for value :String  in importedAccounts as NSArray as [String]
//        {
//            var str = "/Documents/ImportedAccounts/" + value
//            
//            manager.createFileAtPath(NSHomeDirectory().stringByAppendingString(str), contents: NSData(base64EncodedString: HashManager.AES256Encrypt(value, key: value), options: NSDataBase64DecodingOptions()), attributes: nil)
//            
//        }

        ////Test data close

        self.performSegueWithIdentifier(SegueToMainVC, sender: self)

    }
    
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

}

