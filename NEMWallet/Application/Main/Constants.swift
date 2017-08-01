let transferTransaction :Int = 257
let importanceTransaction :Int = 2049
let multisigAggregateModificationTransaction :Int = 4097
let multisigSignatureTransaction :Int = 4098
let multisigTransaction :Int = 4100

let testNetwork :UInt8 = 152
let mainNetwork :UInt8 = 104
let noNetwork :UInt8 = 0
let network :UInt8 = mainNetwork

let genesis_block_time :Double = 1427587585
let waitTime :Double = 21600

let updateInterval :TimeInterval = 30
 
let QR_VERSION = network == testNetwork ? 1 : 2

enum QRKeys: String {
    case Address = "addr"
    case Name = "name"
    case Amount = "amount"
    case Message = "msg"
    case DataType = "type"
    case Data = "data"
    case PrivateKey = "priv_key"
    case Salt = "salt"
    case Version = "v"
}

enum QRType: Int {
    case userData = 1
    case invoice = 2
    case accountData = 3
}

enum _MessageType: Int {
    case normal = 1
    case ecrypted = 2
    case hex = 3
}
