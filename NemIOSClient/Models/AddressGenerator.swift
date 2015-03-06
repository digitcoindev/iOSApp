import UIKit

class AddressGenerator: NSObject
{

    final func generateAddress(publicKey: String)->String
    {
        var inBuffer: Array<UInt8> = Array(publicKey.utf8)
        var stepOneSHA256: Array<UInt8> = Array(count: 64, repeatedValue: 0)
        
        SHA256_hash(&stepOneSHA256, &inBuffer)
        
        var stepOneSHA256Text: String = NSString(bytes: stepOneSHA256, length: stepOneSHA256.count, encoding: NSUTF8StringEncoding) as String
        
        var stepTwoRIPEMD160Text: String = RIPEMD.asciiDigest(stepOneSHA256Text) as String
        var stepTwoRIPEMD160Buffer: Array<UInt8> = Array(stepTwoRIPEMD160Text.utf8)
        
        var version: Array<UInt8> = Array<UInt8>()
        version.append(152)
        
        var stepThreeVersionPrefixedRipemd160Buffer : Array<UInt8> = version + stepTwoRIPEMD160Buffer
        
        var checksumHash: Array<UInt8> = Array(count: 64, repeatedValue: 0)
        
        SHA256_hash(&checksumHash, &stepThreeVersionPrefixedRipemd160Buffer)
        
        var checksum: Array<UInt8> = Array<UInt8>()
        
        checksum.append(checksumHash[0])
        checksum.append(checksumHash[1])
        checksum.append(checksumHash[2])
        checksum.append(checksumHash[3])
        
        var stepFourResultBuffer =  stepThreeVersionPrefixedRipemd160Buffer + checksum
        
        var result :String = Base32Encode(NSData(bytes: stepFourResultBuffer, length: stepFourResultBuffer.count))
        
        return result
    }
}
