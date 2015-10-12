import UIKit
import Contacts

class AddressBookManager: NSObject
{
    //MARK: - Static variables
    
    struct Store {
        static var contactStore = CNContactStore()
        static var contacts :[CNContact] = []
        static var access :Bool = false
    }
    //MARK: - Properties
    
    final class var contacts :[CNContact] {
        get {
            return Store.contacts
        }
    }
    
    final class var contactStore :CNContactStore {
        get {
            return Store.contactStore
        }
    }
    
    final class var isAllowed :Bool? {
        get {
            return _actionWithAccess(nil)
        }
    }
    
    //MARK: - Inizializers
    
    final class func create() {
        refresh(nil)
    }
    
    //MARK: - Controllers
    
    final class func addContact(contact :CNMutableContact, responce: (CNMutableContact? -> Void)?)
    {
        let state = _actionWithAccess({ () -> Void in
            
            let saveRequest = CNSaveRequest()
            saveRequest.addContact(contact, toContainerWithIdentifier:nil)
            do {
                try contactStore.executeSaveRequest(saveRequest)
            } catch let error as NSError {
                print(error)
                responce?(nil)
                return
            }
            
            responce?(contact)
        })
        
        if !(state ?? true) {
            responce?(nil)
        }
    }
    
    final class func updateContact(contact :CNMutableContact, responce: (CNMutableContact? -> Void)?)
    {
        let state = _actionWithAccess({ () -> Void in
            
            let saveRequest = CNSaveRequest()
            saveRequest.updateContact(contact)
            do {
                try contactStore.executeSaveRequest(saveRequest)
            } catch let error as NSError {
                print(error)
                responce?(nil)
                return
            }
            
            responce?(contact)
        })
        
        if !(state ?? true) {
            responce?(nil)
        }
    }
    
    
    final class func deleteContact(contact :CNContact, responce: (Void -> Void)?) {
        let state = _actionWithAccess({ () -> Void in
            let saveRequest = CNSaveRequest()
            saveRequest.deleteContact(contact.mutableCopy() as! CNMutableContact)
            do {
                try contactStore.executeSaveRequest(saveRequest)
            } catch let error as NSError {
                print(error)
                responce?()
                return
            }
            
            responce?()
        })
        
        if !(state ?? true) {
            responce?()
        }
    }
    
    final class func refresh(responce: (Void -> Void)?) {
        let state = _actionWithAccess({ () -> Void in
            
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey]
            let containerId = contactStore.defaultContainerIdentifier()
            let predicate: NSPredicate = CNContact.predicateForContactsInContainerWithIdentifier(containerId)
            
            do {
                Store.contacts = try contactStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
            } catch let error as NSError {
                print(error)
                return
            }
            
            responce?()
        })
        
        if !(state ?? true) {
            responce?()
        }
    }
    
    //MARK: - Private methods
    
    final private class func _actionWithAccess(action :(Void -> Void)?) -> Bool?
    {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            action?()
            return true
            
        case .Denied:
            return false
            
        case .NotDetermined:
            if action != nil {
                self.contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                    if access {
                        action!()
                    }
                })
            }
            
        default:
            return nil
        }
        
        return nil
    }
}
