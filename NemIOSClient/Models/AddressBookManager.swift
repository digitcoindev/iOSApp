import UIKit
import AddressBook

class AddressBookManager: NSObject
{
    //MARK: - Static variables
    
    struct Store {
        static var addressBook : ABAddressBookRef?
        static var contacts :NSArray = NSArray()
        static var access :Bool = false
    }
    //MARK: - Properties
    
    final class var contacts :NSArray {
        get {
            return Store.contacts
        }
    }
    
    final class var addressBook :ABAddressBookRef {
        get {
            return Store.addressBook!
        }
    }
    
    final class var isAllowed :Bool {
        get {
            if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Denied || ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Restricted) {
                return false
            }
            else {
                return true
            }
        }
    }
    
    //MARK: - Inizializers
    
    final class func create() {
        if AddressBookManager.isAllowed
        {
            Store.addressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
            
            ABAddressBookRequestAccessWithCompletion(addressBook,
                {
                    (granted : Bool, error: CFError!) -> Void in
                    if granted == true
                    {
                        Store.contacts = ABAddressBookCopyArrayOfAllPeople(Store.addressBook).takeRetainedValue()
                    }
            })
        }
    }
    
    //MARK: - Controllers
    
    final class func getUserInfoFor(contact :ABRecordRef, responce: (String -> Void)?)
    {
        _actionWithAccess({ () -> Void in
            var title :String = ""
            
            if let name = ABRecordCopyValue(contact, kABPersonFirstNameProperty).takeUnretainedValue() as? NSString {
                title = (name as String)
            }
            
            if let lastName = ABRecordCopyValue(contact, kABPersonLastNameProperty).takeUnretainedValue() as? NSString {
                title = title + " " + (lastName as String)
            }
            
            responce?(title)
        })
    }
    
    final class func getNemAddressFor(contact :ABRecordRef, responce: ([String] -> Void)?)
    {
        _actionWithAccess({ () -> Void in
            var address :[String] = []
            
            let emails: ABMultiValueRef = ABRecordCopyValue(contact, kABPersonEmailProperty).takeRetainedValue()
            let count  :Int = ABMultiValueGetCount(emails)
            
            for var index = 0; index < count; ++index {
                let lable : String = ABMultiValueCopyLabelAtIndex(emails, index).takeRetainedValue() as String
                if lable == "NEM"
                {
                    address.append(ABMultiValueCopyValueAtIndex(emails, index).takeUnretainedValue() as! String)
                }
            }
            
            responce?(address)
        })
    }
    
    final class func changeContact(contact :ABRecordRef, address: String, name: String, surname: String, responce: (Void -> Void)?)
    {
        _actionWithAccess({ () -> Void in
            var error: Unmanaged<CFErrorRef>? = nil
            let propertyType: NSNumber = kABMultiStringPropertyType
            let emails: ABMultiValueRef = Unmanaged.fromOpaque(ABMultiValueCreateMutable(propertyType.unsignedIntValue).toOpaque()).takeUnretainedValue() as NSObject as ABMultiValueRef
            
            ABRecordSetValue(contact, kABPersonFirstNameProperty, name, &error)
            ABRecordSetValue(contact, kABPersonLastNameProperty, surname, &error)
            ABMultiValueAddValueAndLabel(emails, address, "NEM", nil)
            ABRecordSetValue(contact, kABPersonEmailProperty, emails, &error)
            
            if error == nil {
                
                self.save(nil)
                
                responce?()
            } else {
                print("error need to handle")
            }
        })
    }
    
    final class func addContact(name: String, surname: String, address: String, responce: (Void -> Void)?)
    {
        _actionWithAccess({ () -> Void in
            let newContact  :ABRecordRef! = ABPersonCreate().takeRetainedValue()
            let emailMultiValue :ABMutableMultiValueRef = ABMultiValueCreateMutable(ABPropertyType(kABPersonEmailProperty)).takeRetainedValue()
            
            var error: Unmanaged<CFErrorRef>? = nil
            
            ABRecordSetValue(newContact, kABPersonFirstNameProperty, name, &error)
            ABRecordSetValue(newContact, kABPersonLastNameProperty, surname, &error)
            ABMultiValueAddValueAndLabel(emailMultiValue, address, "NEM", nil)
            ABRecordSetValue(newContact, kABPersonEmailProperty, emailMultiValue, &error)
            ABAddressBookAddRecord(Store.addressBook, newContact, &error)
            
            if error == nil {
                self.save(nil)
                
                responce?()
            } else {
                print("error need to handle")
            }
        })
    }
    
    final class func deleteContact(contact :ABRecordRef, responce: (Void -> Void)?) {
        _actionWithAccess({ () -> Void in
            var error: Unmanaged<CFErrorRef>? = nil
            
            ABAddressBookRemoveRecord(addressBook, contact, &error)
            
            if error == nil {
                
                self.save(nil)
                
                responce?()
            } else {
                print("error need to handle")
            }
        })
    }
    
    final class func refresh(responce: (Void -> Void)?) {
        _actionWithAccess({ () -> Void in
            Store.contacts = ABAddressBookCopyArrayOfAllPeople(Store.addressBook).takeRetainedValue()
            responce?()
        })
    }
    
    final class func save(responce: (Void -> Void)?)
    {
        _actionWithAccess({ () -> Void in
            var error: Unmanaged<CFErrorRef>? = nil
            
            ABAddressBookSave(Store.addressBook, &error)
            
            if error == nil {
                responce?()
            } else {
                print("error need to handle")
            }
        })
    }
    
    //MARK: - Private methods
    
    final private class func _actionWithAccess(action :(Void -> Void)?)
    {
        if AddressBookManager.isAllowed {
            if !Store.access {
                ABAddressBookRequestAccessWithCompletion(Store.addressBook,
                    {
                        (granted : Bool, error: CFError!) -> Void in
                        Store.access = granted
                        if granted == true
                        {
                            action?()
                        }
                })
            } else {
                action?()
            }
        }
    }
    
    
}
