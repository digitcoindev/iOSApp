import UIKit


class AddressGenerator: NSObject
{

    final class func generateAddress(publicKey: String)->String {
        var inBuffer: Array<UInt8> = publicKey.asByteArray()

        var stepOneSHA256: Array<UInt8> = Array(count: 64, repeatedValue: 0)
        SHA256_hash(&stepOneSHA256, &inBuffer ,32)
        var stepOneSHA256Text: String = NSString(bytes: stepOneSHA256, length: stepOneSHA256.count, encoding: NSUTF8StringEncoding) as! String
        
        var stepTwoRIPEMD160Text: String = RIPEMD.hexStringDigest(stepOneSHA256Text) as String
        var stepTwoRIPEMD160Buffer: Array<UInt8> = stepTwoRIPEMD160Text.asByteArray()
        
        var version: Array<UInt8> = Array<UInt8>()
        version.append(network)
        
        var stepThreeVersionPrefixedRipemd160Buffer : Array<UInt8> = version + stepTwoRIPEMD160Buffer
        var checksumHash: Array<UInt8> = Array(count: 64, repeatedValue: 0)
        
        SHA256_hash(&checksumHash, &stepThreeVersionPrefixedRipemd160Buffer ,21)
        
        var checksumText: String = NSString(bytes: checksumHash, length: checksumHash.count, encoding: NSUTF8StringEncoding) as! String
        var checksumBuffer: Array<UInt8> = checksumText.asByteArray()
        var checksum: Array<UInt8> = Array<UInt8>()
        checksum.append(checksumBuffer[0])
        checksum.append(checksumBuffer[1])
        checksum.append(checksumBuffer[2])
        checksum.append(checksumBuffer[3])

        var stepFourResultBuffer =  stepThreeVersionPrefixedRipemd160Buffer + checksum
        
        var result :String = Base32Encode(NSData(bytes: stepFourResultBuffer, length: stepFourResultBuffer.count))

        return result
    }
    
    final class func generateAddressFromPrivateKey(privateKey: String)->String {
        var publicKey :String =  KeyGenerator.generatePublicKey(privateKey)
        
        return AddressGenerator.generateAddress(publicKey)
    }
}
