import UIKit

class plistFileManager: NSObject
{
    var fileManager  : FileManager = FileManager()
    var documents : String = NSHomeDirectory() + "/Documents"
    var error: NSError? = nil
    
    var importFiles :NSMutableArray = NSMutableArray()

    override init() {
        super.init()
        
        traceImportFolder()
        refreshImportData()
     }
    
    // Import Accounts

    final func getImportedAccounts() -> NSMutableArray {
        return importFiles
    }
    
    func validatePair(_ way :String , password :String) -> Bool {
        let data = fileManager.contents(atPath: documents + "/NEMfolder/" + way)
        if let str = data?.base64EncodedString(options: NSData.Base64EncodingOptions()) {
            if(HashManager.AES256Decrypt(inputText: str, key: password) == way) {
                return true
            }
        }
        
        return false
    }
    
    final func removeFileAtPath(_ path :String)->Bool {
        if(!fileManager.fileExists(atPath: documents + "/NEMfolder/" + path)) {
            return false
        }
        else {
            do {
                try fileManager.removeItem(atPath: documents + "/NEMfolder/" + path)
            } catch let error1 as NSError {
                error = error1
            }
            return true
        }
    }
    
    final func refreshImportData() ->Bool {
        do {
            let imports =  try fileManager.contentsOfDirectory(atPath: documents + "/NEMfolder")
            
            importFiles = NSMutableArray(array: imports)
            
            return true
        } catch let error1 as NSError {
            error = error1
            print("No accounts found...")
            
            return false
        }
        
    }
    
    final func readErrorLog() ->String? {
        if fileManager.fileExists(atPath: documents + "/NEMfolder") {
            //reading
            let text = try? String(contentsOfFile: documents + "/NEMfolder/error_logs", encoding: String.Encoding.utf8)
            
            return text
        }
        
        return nil
    }
    
    final func writeErrorLog(_ str :String) {
        if(fileManager.fileExists(atPath: documents + "/NEMfolder")) {
            var text :String = "\n"
            
            //reading
            let text2 = try? String(contentsOfFile: documents + "/NEMfolder/error_logs", encoding: String.Encoding.utf8)
            
            text = text2! + text
            do {
                //writing
                try text.write(toFile: documents + "/NEMfolder/error_logs", atomically: false, encoding: String.Encoding.utf8)
            } catch _ {
            }
        }
    }
    
    final func traceImportFolder() {
        if(!fileManager.fileExists(atPath: documents + "/NEMfolder")) {
            print("Add import folder...")
            do {
                try fileManager.createDirectory(atPath: documents + "/NEMfolder", withIntermediateDirectories: false, attributes: nil)
            } catch let error1 as NSError {
                error = error1
            }
            fileManager.createFile(atPath: documents + "/NEMfolder/error_logs", contents: nil, attributes: nil)
        }
    }
    
    final func deleteImportAccount(_ name :String) -> Bool {
        
        if(!fileManager.fileExists(atPath: documents + "/NEMfolder/" + name)) {
            print("Remove imported account")
            
            do {
                try fileManager.removeItem(atPath: documents + "/NEMfolder/" + name)
            } catch let error1 as NSError {
                error = error1
            }
            
            return true
        }
        else {
            return false
        }
        
    }
}
