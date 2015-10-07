
import UIKit


class State: NSObject
{
    struct Store {
        static var stackVC : [String] = [String]()
        static var currentVC : String = ""
        static var toVC : String = ""
        static var currentWallet : Wallet!
        static var currentServer : Server? = CoreDataManager().getLoadData().currentServer
        static var currentContact :Correspondent!
        static var invoice :InvoiceData? = nil

    }
    
    final class var fromVC: String? {
        get {
            return State.Store.stackVC.last
        }
        set {
            if State.Store.stackVC.last != newValue!  {
                State.Store.stackVC.append(newValue!)
            }
        }
    }
    
    final  class var currentVC: String? {
        get {
            return State.Store.currentVC
        }
        set {
            State.Store.currentVC = newValue!
        }
    }
    final class var lastVC:String {
        get {
            var inState = true
            let value = State.Store.stackVC.last!
            for ;inState; {
                if State.Store.stackVC.count > 1 && State.Store.stackVC.last! == value {
                    State.Store.stackVC.removeLast()
                }
                else {
                    inState = false
                }
            }

            return State.Store.stackVC.last!
            
        }
    }
    
    final class var countVC: Int {
        get {
            return State.Store.stackVC.count
        }
       
    }
    
    final class var toVC: String {
        get { return State.Store.toVC }
        set { State.Store.toVC = newValue }
    }
    
    final class var currentWallet: Wallet? {
        get { return State.Store.currentWallet }
        set {
            State.Store.currentWallet = newValue
        }
    }
        
    final class var currentServer: Server? {
        get { return State.Store.currentServer }
        set { State.Store.currentServer = newValue }
    }

    final class var currentContact: Correspondent? {
        get { return State.Store.currentContact }
        set { State.Store.currentContact = newValue}
    }
    
    final class var invoice: InvoiceData? {
        get { return State.Store.invoice }
        set { State.Store.invoice = newValue }
    }
    
    override init() {
        
    }
    
}
