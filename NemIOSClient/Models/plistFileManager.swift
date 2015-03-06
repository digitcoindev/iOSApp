import UIKit

class plistFileManager: NSObject
{
    var fileManager  : NSFileManager = NSFileManager()
    var documents : String = NSHomeDirectory().stringByAppendingString("/Documents")
    var error: NSError? = nil
    
    var uiData : NSMutableDictionary = NSMutableDictionary()
    var importFiles :NSMutableArray = NSMutableArray()

    override init()
    {
        super.init()
        
        uiData = NSMutableDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("UIConfig", ofType: "plist")!)!
        
        traceImportFolder()
        refreshImportData()
        
        
     }
    
    // Import Accounts

    final func getImportedAccounts() -> NSMutableArray
    {
        return importFiles
    }
    
//    func validatePair(way :String , password :String) -> Bool
//    {
//        var data = fileManager.contentsAtPath(documents + "/ImportedAccounts/" + way)
//        if var str = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
//        {
//            var dataManager :CoreDataManager = CoreDataManager()
//            if(HashManager.AES256Decrypt(str, key: password) == way)
//            {
//                dataManager.addWallet(way, password: HashManager.AES256Encrypt(password) )
//                
//                self.removeFileAtPath(way)
//                
//                return true
//            }
//        }
//        
//        return false
//    }
    
    final func removeFileAtPath(path :String)->Bool
    {
        if(!fileManager.fileExistsAtPath(documents + "/ImportedAccounts/" + path))
        {
            return false
        }
        else
        {
            fileManager.removeItemAtPath(documents + "/ImportedAccounts/" + path, error: &error)
            return true
        }
    }
    
    final func refreshImportData() ->Bool
    {
        if var imports =  fileManager.contentsOfDirectoryAtPath(documents + "/ImportedAccounts", error: &error)
        {
            
            importFiles = NSMutableArray(array: imports)
            
            return true
        }
        else
        {
            println("No accounts found...")
            
            return false
        }
        
    }
    
    final func traceImportFolder()
    {
        if(!fileManager.fileExistsAtPath(documents + "/ImportedAccounts"))
        {
            println("Add import folder...")
            fileManager.createDirectoryAtPath(documents + "/ImportedAccounts", withIntermediateDirectories: false, attributes: nil, error: &error)
        }
    }
    
    final func deleteImportAccount(name :String) -> Bool
    {
        
        if(!fileManager.fileExistsAtPath(documents + "/ImportedAccounts/" + name))
        {
            println("Remove imported account")
            
            fileManager.removeItemAtPath(documents + "/ImportedAccounts/" + name, error: &error)
            
            return true
        }
        else
        {
            return false
        }
        
    }
    
    //UIConfig
    
    final func getMenuItems() -> NSMutableArray
    {
        return uiData.objectForKey("mainMenu") as NSMutableArray
    }
    
    //GENERAL
    
    final func commit()
    {
        uiData.writeToFile(NSBundle.mainBundle().pathForResource("UIConfig", ofType: "plist")!, atomically: true)
    }
    
}
