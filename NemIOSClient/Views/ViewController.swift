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
//        transaction.signer = publickey
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
        
//        private key : 856f5bba369241ea2e171c32cb625aa975ec5c53ea0769f30a08f70f455a867e
//        public key : dd13a7d3eec54e859617093f8221ab22357c9925ecdacd3321c7bc07148f9f67
//        address :TCINVPKRY3X24RQMCWZLEEBJQU3GZFKCRW6NK46Y
//        server : 192.168.88.27
        
//        private key : ce6e22753a54a906f009ebee60602ccf9f526497c0bb6d82d4502825d67ad3e2
//        public key : 6edf37401b0023cf0a83a34b5df3d5269f90efcdedc8725145b79050e91daf86
//        address : TB7YNBFV4OLBAJSCTR5Y5QLENEO5U4WMUAMJOZTY
//        server : 192.168.88.27
        
//        private key : eae44d4b5d1214234233f16fc886422d1e02adc24da285e0bbfe735ae8a4d913
//        public key : e6f86ffd64b6a52782617cf8633a937c7d51f80fde03b031c87a45bd2a2f553e
//        address : TDA5FXM2AVAIVJAYO6TY2UY23ULXFIPN35FL32XJ
//        server : 192.168.88.27
        
//        private key : 9bdb9272ed0b7c9deae8e1517bca8bd0df5682095d36b671a7713861a4d822dc
//        public key : dfeb1c9d8a98a61e30d971a4a76d2981d3b4f81d87ec06186f9e31e201687686
//        address : TCQEBHX2PBH44WF22W77ACVRFCULT26YH7L42YEE
//        server : 192.168.88.27
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

}

