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
let SegueToProfile :String = "Profile"

let transferTransaction :Int = 257
let importanceTransaction :Int = 2049
let multisigAggregateModificationTransaction :Int = 4097
let multisigSignatureTransaction :Int = 4098
let multisigTransaction :Int = 4100

let testNetwork :UInt8 = 152
let mainNetwork :UInt8 = 104
let noNetwork :UInt8 = 0
let network :UInt8 = testNetwork

let genesis_block_time :Double = 1427587212
let waitTime :Double = 5400

struct AccountModification
{
    var lengthOfModification :Int!
    var modificationType :Int!
    var lengthOfPublicKey :Int!
    var publicKey :String!
    
    init()
    {
        lengthOfModification = 40
        lengthOfPublicKey = 32
    }
}

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
//
//        //test
//        
        
//        State.currentWallet = dataManager.getWallets().first
//        APIManager().timeSynchronize(State.currentServer!)
//        
//        var transaction :AggregateModificationTransaction = AggregateModificationTransaction()
//        var privateKey = "856f5bba369241ea2e171c32cb625aa975ec5c53ea0769f30a08f70f455a867e"
//        var publickey = KeyGenerator().generatePublicKey(privateKey)
//        
//        transaction.timeStamp = 1517033
//        transaction.deadline = 1517033 + waitTime
//        transaction.version = 1
//        transaction.signer =Server is publickey
//        transaction.privateKey = privateKey
//        transaction.addModification(2, publicKey: "e6f86ffd64b6a52782617cf8633a937c7d51f80fde03b031c87a45bd2a2f553e")
//        transaction.fee = 10 + 6 * Double(transaction.modifications.count)
//
//        
//        APIManager().prepareAnnounce(State.currentServer!, transaction: transaction)
        
        //test
        
        
        self.performSegueWithIdentifier(SegueToMainVC, sender: self)
        
//        self.presentViewController(alert1, animated: true, completion: nil)
        
//        private key : 5ccf739d9f40f981e100492632cf729ae7940980e677551684f4f309bac5c59d
//        public key : cba08dd72505e0c6aa0b7521598c7c63ecef72bd48175355f9dd977664e4fcd1
//        address :TCUPVQC77TAMH7QKPFP5OT3TLUV4JYRPV6CEGJXW
//        server : 192.168.88.27

//        Private key : 4c6516bd4068ced18f5f629402145cfaaae904e528a7311df03bc0006eb98f56
//        Public key : 6665dd6d4116d9193a182d6d12952f44038e3118304885d3038bd60c9554c966
//        Address : TCQY35AAV6BO5SRUPCLIZKIVBZASHQDSSCRY3PTE
//        
//        Private key : 4c6516bd4068ced18f5f629402145cfaaae904e528a7311df03bc0006eb98f56
//        Public key : 6665dd6d4116d9193a182d6d12952f44038e3118304885d3038bd60c9554c966
//        Address : TCQY35AAV6BO5SRUPCLIZKIVBZASHQDSSCRY3PTE
//        
//        Private key : 4c6516bd4068ced18f5f629402145cfaaae904e528a7311df03bc0006eb98f56
//        Public key : 6665dd6d4116d9193a182d6d12952f44038e3118304885d3038bd60c9554c966
//        Address : TCQY35AAV6BO5SRUPCLIZKIVBZASHQDSSCRY3PTE
//        
//        Private key : 4c6516bd4068ced18f5f629402145cfaaae904e528a7311df03bc0006eb98f56
//        Public key : 6665dd6d4116d9193a182d6d12952f44038e3118304885d3038bd60c9554c966
//        Address : TCQY35AAV6BO5SRUPCLIZKIVBZASHQDSSCRY3PTE
//        
//        Private key : 4c6516bd4068ced18f5f629402145cfaaae904e528a7311df03bc0006eb98f56
//        Public key : 6665dd6d4116d9193a182d6d12952f44038e3118304885d3038bd60c9554c966
//        Address : TCQY35AAV6BO5SRUPCLIZKIVBZASHQDSSCRY3PTE
//        
//        Private key : 4c6516bd4068ced18f5f629402145cfaaae904e528a7311df03bc0006eb98f56
//        Public key : 6665dd6d4116d9193a182d6d12952f44038e3118304885d3038bd60c9554c966
//        Address : TCQY35AAV6BO5SRUPCLIZKIVBZASHQDSSCRY3PTE
//        
//        Private key : 4c6516bd4068ced18f5f629402145cfaaae904e528a7311df03bc0006eb98f56
//        Public key : 6665dd6d4116d9193a182d6d12952f44038e3118304885d3038bd60c9554c966
//        Address : TCQY35AAV6BO5SRUPCLIZKIVBZASHQDSSCRY3PTE
//        
//        Private key : 4c6516bd4068ced18f5f629402145cfaaae904e528a7311df03bc0006eb98f56
//        Public key : 6665dd6d4116d9193a182d6d12952f44038e3118304885d3038bd60c9554c966
//        Address : TCQY35AAV6BO5SRUPCLIZKIVBZASHQDSSCRY3PTE
//        
//        Private key : 4c6516bd4068ced18f5f629402145cfaaae904e528a7311df03bc0006eb98f56
//        Public key : 6665dd6d4116d9193a182d6d12952f44038e3118304885d3038bd60c9554c966
//        Address : TCQY35AAV6BO5SRUPCLIZKIVBZASHQDSSCRY3PTE
//        
//        Private key : 4c6516bd4068ced18f5f629402145cfaaae904e528a7311df03bc0006eb98f56
//        Public key : 6665dd6d4116d9193a182d6d12952f44038e3118304885d3038bd60c9554c966
//        Address : TCQY35AAV6BO5SRUPCLIZKIVBZASHQDSSCRY3PTE
//        
//        Private key : 4c6516bd4068ced18f5f629402145cfaaae904e528a7311df03bc0006eb98f56
//        Public key : 6665dd6d4116d9193a182d6d12952f44038e3118304885d3038bd60c9554c966
//        Address : TCQY35AAV6BO5SRUPCLIZKIVBZASHQDSSCRY3PTE
//        
//        Private key : 4c6516bd4068ced18f5f629402145cfaaae904e528a7311df03bc0006eb98f56
//        Public key : 6665dd6d4116d9193a182d6d12952f44038e3118304885d3038bd60c9554c966
//        Address : TCQY35AAV6BO5SRUPCLIZKIVBZASHQDSSCRY3PTE
//        
//        Private key : 4c6516bd4068ced18f5f629402145cfaaae904e528a7311df03bc0006eb98f56
//        Public key : 6665dd6d4116d9193a182d6d12952f44038e3118304885d3038bd60c9554c966
//        Address : TCQY35AAV6BO5SRUPCLIZKIVBZASHQDSSCRY3PTE
//        
//        Private key : 4c6516bd4068ced18f5f629402145cfaaae904e528a7311df03bc0006eb98f56
//        Public key : 6665dd6d4116d9193a182d6d12952f44038e3118304885d3038bd60c9554c966
//        Address : TCQY35AAV6BO5SRUPCLIZKIVBZASHQDSSCRY3PTE
//        
//        Private key : 4c6516bd4068ced18f5f629402145cfaaae904e528a7311df03bc0006eb98f56
//        Public key : 6665dd6d4116d9193a182d6d12952f44038e3118304885d3038bd60c9554c966
//        Address : TCQY35AAV6BO5SRUPCLIZKIVBZASHQDSSCRY3PTE
//        
//        Private key : 4c6516bd4068ced18f5f629402145cfaaae904e528a7311df03bc0006eb98f56
//        Public key : 6665dd6d4116d9193a182d6d12952f44038e3118304885d3038bd60c9554c966
//        Address : TCQY35AAV6BO5SRUPCLIZKIVBZASHQDSSCRY3PTE
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

}

