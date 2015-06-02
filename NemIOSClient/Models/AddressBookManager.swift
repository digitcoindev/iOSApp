import UIKit
import AddressBook

class AddressBookManager: NSObject
{
    struct Store
    {
        static var addressBook : ABAddressBookRef?
        static var contacts :NSArray = NSArray()
    }
    
    final class var contacts :NSArray
    {
        get
        {
            return Store.contacts
        }
    }
    
    final class var addressBook :ABAddressBookRef
    {
        get
        {
            return Store.addressBook!
        }
    }
    
    final class var isAllowed :Bool
    {
        get
        {
            if (ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Denied || ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Restricted)
            {
                return false
            }
            else
            {
                return true
            }
        }
    }
    
    final class func create()
    {
       if AddressBookManager.isAllowed
       {
            Store.addressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
            
            ABAddressBookRequestAccessWithCompletion(addressBook,
            {
                success, error in
                
                if success
                {
                    ABAddressBookRequestAccessWithCompletion(Store.addressBook,
                        {
                            (granted : Bool, error: CFError!) -> Void in
                            if granted == true
                            {
                                Store.contacts = ABAddressBookCopyArrayOfAllPeople(Store.addressBook).takeRetainedValue()
                            }
                    })
                }
            })
        }
    }
    
    final class func refresh()
    {
        if AddressBookManager.isAllowed
        {
            Store.contacts = ABAddressBookCopyArrayOfAllPeople(Store.addressBook).takeRetainedValue()
        }
    }
}
