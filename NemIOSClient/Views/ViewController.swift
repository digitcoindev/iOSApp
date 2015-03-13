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

        println(NSDate(timeIntervalSince1970: 6661052000 + 16171000))
       self.performSegueWithIdentifier(SegueToMainVC, sender: self)
        
    
        
//        var alert1 :UIAlertController = UIAlertController(title: "Add NEM account", message: "Input your data", preferredStyle: UIAlertControllerStyle.Alert)
//       
//        
//        self.presentViewController(alert1, animated: true, completion: nil)
    }

//
//    func packString(string:String, bytes:[UInt8]) -> [UInt8]
//    {
//        var localBytes:Array<UInt8> = bytes
//
//        var stringBuff = [UInt8]()
//        stringBuff += string.utf8
//
//        var length = stringBuff.count
//        if (length < 0x20)
//        {
//            localBytes.append(UInt8(0xA0 | UInt8(length)))
//        }
//        else
//        {
//            if (length < 0x10)
//            {
//                localBytes.append(UInt8(0xD9))
//            }
//            else if (length < 0x100)
//            {
//                localBytes.append(UInt8(0xDA))
//            }
//            else
//            {
//                localBytes.append(UInt8(0xDB))
//            }
//
//            localBytes += lengthBytes(Int32(length))
//        }
//        
//        localBytes += stringBuff
//        
//        return localBytes
//    }
//    
//    func lengthBytes(lengthIn:Int32) -> Array<UInt8>
//    {
//        var length:CLong = CLong(lengthIn)
//        var lengthBytes:Array<UInt8> = Array<UInt8>()
//        
//        switch (length)
//        {
//        case 0..<0x10:
//            lengthBytes.append(UInt8(length))
//            
//        case 0x10..<0x100:
//            lengthBytes = Array<UInt8>(count:2, repeatedValue:0)
//            memcpy(&lengthBytes, &length, 2)
//            lengthBytes = lengthBytes.reverse()
//            
//        case 0x100..<0x10000:
//            lengthBytes = Array<UInt8>(count:4, repeatedValue:0)
//            memcpy(&lengthBytes, &length, 4)
//            lengthBytes = lengthBytes.reverse()
//            
//        default:
//            break;
//        }
//        
//        return lengthBytes
//    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

}

