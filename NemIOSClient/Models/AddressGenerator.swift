import UIKit


class AddressGenerator: NSObject
{

    final func generateAddress(publicKey: String)->String
    {
        println("start")
        var inBuffer: Array<UInt8> = publicKey.asByteArray()

        var stepOneSHA256: Array<UInt8> = Array(count: 64, repeatedValue: 0)
        SHA256_hash(&stepOneSHA256, &inBuffer ,32)
        var stepOneSHA256Text: String = NSString(bytes: stepOneSHA256, length: stepOneSHA256.count, encoding: NSUTF8StringEncoding) as! String
        println("1")
        var stepTwoRIPEMD160Text: String = RIPEMD.hexStringDigest(stepOneSHA256Text) as String
        println("2")
        var stepTwoRIPEMD160Buffer: Array<UInt8> = stepTwoRIPEMD160Text.asByteArray()
        println("4")
        var version: Array<UInt8> = Array<UInt8>()
        version.append(network) 
        
        var stepThreeVersionPrefixedRipemd160Buffer : Array<UInt8> = version + stepTwoRIPEMD160Buffer
        println("6")
        var checksumHash: Array<UInt8> = Array(count: 64, repeatedValue: 0)
        SHA256_hash(&checksumHash, &stepThreeVersionPrefixedRipemd160Buffer ,21)
        var checksumText: String = NSString(bytes: checksumHash, length: checksumHash.count, encoding: NSUTF8StringEncoding) as! String
        var checksumBuffer: Array<UInt8> = checksumText.asByteArray()
        println("8")
        var checksum: Array<UInt8> = Array<UInt8>()
        checksum.append(checksumBuffer[0])
        checksum.append(checksumBuffer[1])
        checksum.append(checksumBuffer[2])
        checksum.append(checksumBuffer[3])
        println("10")
        var stepFourResultBuffer =  stepThreeVersionPrefixedRipemd160Buffer + checksum
        var result :String = Base32Encode(NSData(bytes: stepFourResultBuffer, length: stepFourResultBuffer.count))
        println("end")

        return result
    }
    
    final func generateAddressFromPrivateKey(privateKey: String)->String
    {
        var publicKey :String =  KeyGenerator().generatePublicKey(privateKey)
        
        return generateAddress(publicKey)
    }
}
