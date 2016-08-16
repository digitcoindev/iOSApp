struct AccountModification
{
    var lengthOfModification :Int!
    var modificationType :Int!
    var lengthOfPublicKey :Int!
    var publicKey :String!
    
    init() {
        lengthOfModification = 40
        lengthOfPublicKey = 32
    }
}

struct InvoiceData
{
    var address :String!
    var amount :Double!
    var message :String!
    var name :String!
    var number :Int!
    
    init() {
        message = ""
        amount = 0
        number = 0
        if State.currentWallet != nil {
            name = State.currentWallet!.login
        }
        else {
            name = ""
        }
    }
}

struct CorrespondentCellData
{
    var correspondent :_Correspondent!
    var lastMessage :TransferTransaction?
}