
import UIKit


class State: NSObject
{
    fileprivate struct Store {
        static var stackVC : [String] = [String]()
        static var currentVC : String = ""
        static var toVC : String = ""
        static var nextVC :String = ""
//        static var loadData :LoadData? = CoreDataManager().getLoadData()
//        static var currentWallet : Wallet? = CoreDataManager().getLoadData().currentWallet
//        static var currentServer : Server? = CoreDataManager().getLoadData().currentServer
        static var currentContact :_Correspondent!
        static var invoice :InvoiceData? = nil
        static var exportAccount :String? = nil
    }
    
    fileprivate struct ImportStore {
        static var isAccount: Bool = false
        static var passwordCompletitionBlock :((_ password: String)->Bool)? = nil
    }
    
    final class var exportAccount: String? {
        get {
        return State.Store.exportAccount
        }
        set {
            State.Store.exportAccount = newValue
        }
    }
    
    final class var loadData: LoadData? {
        get {
//            return State.Store.loadData
            return nil
        }
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
    
    final class func cleanVCs() {
        State.Store.stackVC = []
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
    
    final class var nextVC: String {
        get { return State.Store.nextVC }
        set { State.Store.nextVC = newValue }
    }
    
    final class var currentWallet: Wallet? {
//        get { return State.Store.currentWallet }
//        set {
//            State.Store.currentWallet = newValue
//        }
        return nil
    }
        
    final class var currentServer: Server? {
//        get { return State.Store.currentServer }
//        set { State.Store.currentServer = newValue }
        
        return nil
    }

    final class var currentContact: _Correspondent? {
        get { return State.Store.currentContact }
        set { State.Store.currentContact = newValue}
    }
    
    final class var invoice: InvoiceData? {
        get { return State.Store.invoice }
        set { State.Store.invoice = newValue }
    }
    
    final class var importAccountData:((_ password: String)->Bool)? {
        get { return (State.ImportStore.isAccount) ? State.ImportStore.passwordCompletitionBlock : nil}
        set {
                State.ImportStore.isAccount = (newValue == nil) ? false : true
                State.ImportStore.passwordCompletitionBlock = newValue
            }
        }
    
    override init() {
        
    }
    
}
