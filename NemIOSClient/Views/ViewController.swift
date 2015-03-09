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
var SegueToAddFriend :String = "Add Friend"

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
        
        var privateKey =  "3139211773934fdda4b62282eb6f144fb8cdb7e10a508196d3d884423e470154"
        var publicKey = "bb0aace5b35fd13d24833e4719665183a765097f763ce9d7a7a85c1dd57874e8"
        var address = AddressGenerator().generateAddress(publicKey)
        
        println("private key : \(privateKey)")
        println("public key : \(publicKey)")
        println("address : \(address)")
        
        ////Test data close

        self.performSegueWithIdentifier(SegueToMainVC, sender: self)

    }
    
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

}

