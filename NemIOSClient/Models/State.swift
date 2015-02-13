import UIKit


class State: NSObject
{
    struct Store
        {
        static var stackVC : [String] = [String]()
        static var currentVC : String = ""
        static var toVC : String = ""
        static var currentWallet : Wallet!
        static var currentServer : Server = CoreDataManager().getLoadData().currentServer
        static var currentContact :Correspondent!
    }
    
    class var fromVC: String?
    {
        get
        {
            return State.Store.stackVC.last
        }
        set
        {
            State.Store.stackVC.append(newValue!)
            println("Append : "  + newValue!)
        }
    }
    
    class var currentVC: String?
    {
        get
        {
            return State.Store.currentVC
        }
        set
        {
            State.Store.currentVC = newValue!
        }
    }
    class var lastVC:String
    {
        get
        {
            for str in Store.stackVC
            {
                println(str)
            }
            
            if State.Store.stackVC.count > 1
            {
                State.Store.stackVC.removeLast()
            }

            return State.Store.stackVC.last!
            
        }
    }
    
    class var countVC: Int
    {
        get
        {
            return State.Store.stackVC.count
        }
       
    }
    
    class var toVC: String
        {
        get { return State.Store.toVC }
        set { State.Store.toVC = newValue }
    }
    
    class var currentWallet: Wallet?
        {
        get { return State.Store.currentWallet }
        set { State.Store.currentWallet = newValue! }
    }
    
    class var currentServer: Server?
        {
        get { return State.Store.currentServer }
        set { State.Store.currentServer = newValue! }
    }

    class var currentContact: Correspondent?
        {
        get { return State.Store.currentContact }
        set { State.Store.currentContact = newValue!}
    }
    
    override init()
    {
        
    }
    
}
