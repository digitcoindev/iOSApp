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
let SegueToMessageMultisignVC : String =  "Message2"
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
let SegueToProfileMultisig :String = "ProfileMultisig"
let SegueToProfileCosignatoryOf :String = "ProfileCosignatoryOf"
let SegueToSendTransaction :String = "SendTransaction"
let SegueTomultisigAccountManager :String = "multisigAccountManager"
let SegueToUnconfirmedTransactionVC :String = "UnconfirmedTransactionVC"
let SegueToHistoryVC :String = "History"

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
let waitTime :Double = 21600

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
        
        var errorLogs = plistFileManager().readErrorLog()
        if errorLogs != nil
        {
            if errorLogs != ""
            {
                var alert :UIAlertView = UIAlertView(title: "Info", message: "Error copied to pasteboard ", delegate: self, cancelButtonTitle: "OK")
                alert.show()

                UIPasteboard.generalPasteboard().string = errorLogs
            }
        }
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
        
//        private key : 168fd919078c8a2fb04183c6214ca80e9aed8ebd2fe1dd283f12cab869678bfd
//        public key : abac2ee3d4aaa7a3bfb65261a00cc04c761521527dd3f2cf741e2815cbba83ac
//        address key : TCRXYUQIMFA7AOGL5LF3YWLC7VABLYUMJ5ACBUNL
//
//        private key : 6ffa04f529d52354fe139172d0529d9710065ff0ecaba60bf2233ad06731c1ba
//        public key : 59d89076964742ef2a2089d26a5aa1d2c7a7bb052a46c1de159891e91ad3d76e
//        address key : TCQOCOKR5PGFUGIPPU27U3ATVS5KMVYK6C4UT7PA
//
//        private key : 0560458ac2789c5998f576f8eced7cc0c6d1aa74006993ead764dc0a7456db8b
//        public key : 71cba4f2a28fd19f902ba40e9937994154d9eeaad0631d25d525ec37922567d4
//        address key : TAQIFDDNMV3AHBWOBNGF6AT4WDKOU7UZKY2X4OQ5
//        
//        private key : 05a4f584cfcd87165e2db6d1e960f331541114dcf18e557228bb288983e34ca9
//        public key : e6cff9b3725a91f31089c3acca0fac3e341c00b1c8c6e9578f66c4514509c3b3
//        address key : TCFSD4FFR3SSWU6QWWEE4KPFBJ637WVGYCYK4PV2
//
//        private key : 3faca9b879b728bd3763bc35d3c288086f19427057c148e56f3c6f0c0237eee2
//        public key : d6afb4ddc75f3a1c7fd3430f0a2ebe971b6bd9f56b875cfb044356492bc28572
//        address key : TBUFO6OZV2TBKIFE5MLIFAIHONCNDDPZ2CZCCSKE
//                
//        private key : 97a062d646085bb1e0f00836999cdb2ec211b594eb61a182878f5e359e0323f6
//        public key : 43b84ed28b627fbcb3aa586f7192ae6e5a4b9ebacff0135d961346547d4f9873
//        address key : TC7EZMI3MPOX2EIPUVHYQ655IXB74CSOXKQTJKLM
//
//        private key : 9eb58e385e2db820938a03eb226ee6a6ca7b0f8fee91596b2df377fcacd56b45
//        public key : a2994a0efa0999aa88eabeb49ec3d80de09f6f895f123b8c004d82a0b9ba83c9
//        address key : TAKQ4LOUD7RTMDHPFT6HKXHCE6JCESOIKZCQKIUW
//        
//        private key : afa9f13089ce637d2cc32411b69f48c1d69ffaf28ee5b0f2b3441c4fc3a33a64
//        public key : 99526f2542d83a0cec7f3d6c2d9cb51195f15b6ecc3af1ede2b8d98c5821f5e7
//        address key : TA55BMUFQP64RDV3MRONYNI6KQ7GXTYU7VHGRKML
//        
//        private key : 5884635bffe4c06fc7592e1d93724d4d115f05853165cd7f84cea511da8573ab
//        public key : bae12db8f2db450fb09b0500003d2ed401cd5453d47942490ed255a2f4d3bd37
//        address key : TDSXT6ZER42QN7YEYZLFVX3CLZNUX4IAZTBYF4WX
//        
//        private key : 8904eec52f0efa3cf949eb886de47edd49c993266b58875cf0f59510d3e0febb
//        public key : 14dd41fa256cf52f3256ecfbc1b459d36f7b5a1aa6a667ba20ce0f21ed39a3f5
//        address key : TAAX47Q5XQ73ETZT6GT264MXAKOXJAVVUUT6YCBP
//        
//        private key : 0ffc92a6d19ce6c0677bf358eda432ef87651586bedda1e6e475b171f208c289
//        public key : c231436dc2cac8d40e61dbc9b977970d4a16ad3219c178cabc978a00bd03858f
//        address key : TCWWLBOVPW33ACNS7GQ3QDJQG7OS2RWWIDCKBXYS
//        
//        private key : 71a1b16d071a905c17c74c4d07b8f5b912139f3049de17d9c9ec7bd635f0d006
//        public key : 84767162b24997ed8244fca7da1031f29a5a7a7545b4a930aa3b48f7aa9e8c85
//        address key : TDRXHLOMOUMAEDJVJFPDFLUC4A25QEL72PFWS2AW
//        
//        private key : 00e87c54cccf5949dca54be4ab15c3f65e39ca8e84f7330093f5dc940c59ac63
//        public key : 0fb6a4f54799d071f009cc14d00cd730c7c5e1c31948b3fe55d4c244b4647b07
//        address key : TBE7R4SXOZXLQMAACBZVA4LGR2664FBVDKBCMCNO
//        
//        private key : 0c96b38ced07b9877804d136ba77d08b4349eb97d554d8a48aca810cd3e5e046
//        public key : 9204d43781eec66738815c75e2ff97dbdbab3a630c2e57cda90a0dc4bbcf657a
//        address key : TA44JISEU6ZHLFPIZVJC74I7MFBT6WTCUBSWENO5
//        
//        private key : fc4cab81fa2bf70197998a35ed8929fdbfeee9beae2fcac3063e8727506fe607
//        public key : 1411fb8bfb445725969648579e83d0e1f2b0e1fb91f5c6c65942efc3772443ff
//        address key : TCXKX7BR7Q7UKH5ZHRCJGG6GCLKDIERJYNGOEIRF
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

}

